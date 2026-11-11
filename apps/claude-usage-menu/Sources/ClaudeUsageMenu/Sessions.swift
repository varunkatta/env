import Darwin
import Foundation

/// A Claude Code session whose process is still alive on this machine.
struct LiveSession {
    let pid: Int32
    let sessionId: String
    let cwd: String
    let name: String?
    let startedAt: Date?
    var model: String?
    var contextTokens: Int?
    var lastActivity: Date?
    /// `raw_max_tokens` from a `contextUsage` record, when the transcript happens to carry one.
    var reportedContextLimit: Int?

    /// Fallback when no `contextUsage` record is in reach: the smallest published tier that still
    /// fits what has been used.
    static let contextTiers = [200_000, 1_000_000]

    var contextLimit: Int? {
        if let reportedContextLimit { return reportedContextLimit }
        guard let contextTokens else { return nil }
        return Self.contextTiers.first { contextTokens <= $0 } ?? Self.contextTiers.last
    }

    /// True when the window came from Claude Code rather than being guessed.
    var contextLimitIsReported: Bool { reportedContextLimit != nil }

    var contextFraction: Double? {
        guard let contextTokens, let contextLimit, contextLimit > 0 else { return nil }
        return Double(contextTokens) / Double(contextLimit)
    }

    var label: String {
        if let name, !name.isEmpty { return name }
        return (cwd as NSString).lastPathComponent
    }
}

private struct SessionFile: Decodable {
    let pid: Int32
    let sessionId: String
    let cwd: String
    let name: String?
    let startedAt: Double?
}

/// Reads live-session state from `~/.claude`. Everything here is local file I/O — no network,
/// no credentials, and no writes.
struct SessionReader {
    private let root = ClaudeConfig.directory

    /// Only the tail of a transcript is read; the newest usage block is all that matters and
    /// transcripts routinely reach tens of megabytes. A single large tool result can fill the
    /// first window on its own, so a second, wider read is tried before giving up.
    private static let transcriptTailWindows = [512 * 1024, 8 * 1024 * 1024]

    /// How much later than the session's recorded start its process may have started. A pid whose
    /// process started after this is a different program that reused the pid.
    private static let pidReuseTolerance: TimeInterval = 120

    func liveSessions() -> [LiveSession] {
        let sessionsDir = root.appendingPathComponent("sessions")
        let entries = (try? FileManager.default.contentsOfDirectory(at: sessionsDir,
                                                                    includingPropertiesForKeys: nil)) ?? []
        var index: [String: URL]?

        var sessions: [LiveSession] = []
        var seen = Set<String>()
        for entry in entries where entry.pathExtension == "json" {
            guard let data = try? Data(contentsOf: entry),
                  let decoded = try? JSONDecoder().decode(SessionFile.self, from: data)
            else { continue }

            let startedAt = decoded.startedAt.flatMap { $0 > 0 ? Date(timeIntervalSince1970: $0 / 1000) : nil }
            guard isAlive(decoded.pid, sessionStartedAt: startedAt),
                  seen.insert(decoded.sessionId).inserted
            else { continue }

            var session = LiveSession(
                pid: decoded.pid,
                sessionId: decoded.sessionId,
                cwd: decoded.cwd,
                name: decoded.name,
                startedAt: startedAt,
                model: nil,
                contextTokens: nil,
                lastActivity: nil,
                reportedContextLimit: nil
            )

            var transcript = directTranscript(sessionId: decoded.sessionId, cwd: decoded.cwd)
            if transcript == nil {
                // Built at most once per pass, and only when the direct path misses.
                if index == nil { index = transcriptIndex() }
                transcript = index?[decoded.sessionId]
            }
            if let transcript {
                applyContext(from: transcript, to: &session)
            }
            sessions.append(session)
        }

        return sessions.sorted { ($0.contextTokens ?? -1) > ($1.contextTokens ?? -1) }
    }

    // MARK: - Process liveness

    /// A session file lingers after its process exits, and macOS reuses pids, so a pid that is
    /// running is only accepted when its process started no later than the session did.
    private func isAlive(_ pid: Int32, sessionStartedAt: Date?) -> Bool {
        guard pid > 0, kill(pid, 0) == 0 || errno == EPERM else { return false }
        guard let sessionStartedAt, let processStartedAt = Self.processStartTime(pid) else { return true }
        return processStartedAt.timeIntervalSince(sessionStartedAt) <= Self.pidReuseTolerance
    }

    static func processStartTime(_ pid: Int32) -> Date? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, pid]
        guard sysctl(&mib, 4, &info, &size, nil, 0) == 0, size > 0 else { return nil }
        let start = info.kp_proc.p_un.__p_starttime
        guard start.tv_sec > 0 else { return nil }
        return Date(timeIntervalSince1970: Double(start.tv_sec) + Double(start.tv_usec) / 1_000_000)
    }

    // MARK: - Transcripts

    /// Claude Code stores a session's transcript under `projects/<cwd with every
    /// non-alphanumeric character replaced by "-">/<sessionId>.jsonl`.
    private func directTranscript(sessionId: String, cwd: String) -> URL? {
        let encoded = String(cwd.map { $0.isASCII && ($0.isLetter || $0.isNumber) ? $0 : "-" })
        let url = root.appendingPathComponent("projects")
            .appendingPathComponent(encoded)
            .appendingPathComponent("\(sessionId).jsonl")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    /// Maps sessionId to transcript path across every project directory.
    private func transcriptIndex() -> [String: URL] {
        let projects = root.appendingPathComponent("projects")
        let dirs = (try? FileManager.default.contentsOfDirectory(at: projects,
                                                                 includingPropertiesForKeys: nil)) ?? []
        var index: [String: URL] = [:]
        for dir in dirs {
            let files = (try? FileManager.default.contentsOfDirectory(at: dir,
                                                                      includingPropertiesForKeys: nil)) ?? []
            for file in files where file.pathExtension == "jsonl" {
                index[file.deletingPathExtension().lastPathComponent] = file
            }
        }
        return index
    }

    /// The newest main-thread assistant message carries the context the model actually saw on that
    /// turn, which already accounts for any compaction that has happened.
    private func applyContext(from transcript: URL, to session: inout LiveSession) {
        guard let handle = try? FileHandle(forReadingFrom: transcript) else { return }
        defer { try? handle.close() }
        guard let size = try? handle.seekToEnd() else { return }

        for window in Self.transcriptTailWindows {
            let offset = size > UInt64(window) ? size - UInt64(window) : 0
            try? handle.seek(toOffset: offset)
            guard let data = try? handle.readToEnd() else { return }

            var lines = data.split(separator: 0x0A, omittingEmptySubsequences: true)
            if offset > 0, !lines.isEmpty {
                lines.removeFirst() // Partial line left by the byte-offset seek.
            }
            Self.scan(lines: lines, into: &session)

            // Done once the turn is found, or once the whole file has been read.
            if session.contextTokens != nil || offset == 0 { return }
        }
    }

    /// Walking backwards finds the newest of each record first. The true window size comes from a
    /// `contextUsage` record, which Claude Code only writes when the context view has been opened,
    /// so it may be absent.
    static func scan(lines: [Data.SubSequence], into session: inout LiveSession) {
        for line in lines.reversed() {
            guard let entry = try? JSONSerialization.jsonObject(with: Data(line)) as? [String: Any]
            else { continue }

            if session.reportedContextLimit == nil,
               let context = entry["contextUsage"] as? [String: Any],
               let maxTokens = (context["raw_max_tokens"] as? NSNumber)?.intValue, maxTokens > 0 {
                session.reportedContextLimit = maxTokens
            }

            if session.contextTokens == nil, let turn = assistantTurn(entry) {
                session.contextTokens = turn.tokens
                session.model = turn.model
                session.lastActivity = turn.timestamp
            }

            if session.contextTokens != nil, session.reportedContextLimit != nil { return }
        }
    }

    /// A main-thread assistant turn that reached the API. Subagent (sidechain) turns carry the
    /// subagent's own, much smaller, context; synthetic turns (written locally after an error or an
    /// interrupt) carry zeroed usage. Neither says anything about the session's context.
    private static func assistantTurn(_ entry: [String: Any]) -> (tokens: Int, model: String?, timestamp: Date?)? {
        guard entry["type"] as? String == "assistant",
              (entry["isSidechain"] as? Bool) != true,
              (entry["isApiErrorMessage"] as? Bool) != true,
              let message = entry["message"] as? [String: Any],
              let usage = message["usage"] as? [String: Any]
        else { return nil }

        let model = message["model"] as? String
        if model == "<synthetic>" { return nil }

        func count(_ key: String) -> Int { (usage[key] as? NSNumber)?.intValue ?? 0 }
        let tokens = count("input_tokens") + count("cache_read_input_tokens") + count("cache_creation_input_tokens")
        guard tokens > 0 else { return nil }

        let timestamp = (entry["timestamp"] as? String).flatMap(StatusFeed.parseISO)
        return (tokens, model, timestamp)
    }
}
