import Foundation

/// A Claude Code session whose process is still alive on this machine.
struct LiveSession {
    let pid: Int32
    let sessionId: String
    let cwd: String
    let name: String?
    let startedAt: Date
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
    private let root = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")

    /// Only the tail of a transcript is read; the newest usage block is all that matters and
    /// transcripts routinely reach tens of megabytes.
    private static let transcriptTailBytes = 512 * 1024

    func liveSessions() -> [LiveSession] {
        let sessionsDir = root.appendingPathComponent("sessions")
        let entries = (try? FileManager.default.contentsOfDirectory(at: sessionsDir,
                                                                    includingPropertiesForKeys: nil)) ?? []
        let transcripts = transcriptIndex()

        var sessions: [LiveSession] = []
        for entry in entries where entry.pathExtension == "json" {
            guard let data = try? Data(contentsOf: entry),
                  let decoded = try? JSONDecoder().decode(SessionFile.self, from: data),
                  isAlive(decoded.pid)
            else { continue }

            var session = LiveSession(
                pid: decoded.pid,
                sessionId: decoded.sessionId,
                cwd: decoded.cwd,
                name: decoded.name,
                startedAt: Date(timeIntervalSince1970: (decoded.startedAt ?? 0) / 1000),
                model: nil,
                contextTokens: nil,
                lastActivity: nil,
                reportedContextLimit: nil
            )
            if let transcript = transcripts[decoded.sessionId] {
                applyContext(from: transcript, to: &session)
            }
            sessions.append(session)
        }

        return sessions.sorted { ($0.contextTokens ?? -1) > ($1.contextTokens ?? -1) }
    }

    /// A session file lingers briefly after its process exits, so the pid is probed directly.
    private func isAlive(_ pid: Int32) -> Bool {
        guard pid > 0 else { return false }
        return kill(pid, 0) == 0 || errno == EPERM
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

    /// The newest assistant message carries the context the model actually saw on that turn,
    /// which already accounts for any compaction that has happened.
    private func applyContext(from transcript: URL, to session: inout LiveSession) {
        guard let handle = try? FileHandle(forReadingFrom: transcript) else { return }
        defer { try? handle.close() }

        guard let size = try? handle.seekToEnd() else { return }
        let offset = size > UInt64(Self.transcriptTailBytes) ? size - UInt64(Self.transcriptTailBytes) : 0
        try? handle.seek(toOffset: offset)
        guard let data = try? handle.readToEnd() else { return }

        var lines = data.split(separator: 0x0A, omittingEmptySubsequences: true)
        if offset > 0, !lines.isEmpty {
            lines.removeFirst() // Partial line left by the byte-offset seek.
        }

        // Walking backwards finds the newest of each record first. The live context comes from the
        // last assistant turn; the true window size comes from a `contextUsage` record, which
        // Claude Code only writes when the context view has been opened, so it may be absent.
        for line in lines.reversed() {
            guard let entry = try? JSONSerialization.jsonObject(with: Data(line)) as? [String: Any]
            else { continue }

            if session.reportedContextLimit == nil,
               let context = entry["contextUsage"] as? [String: Any],
               let maxTokens = context["raw_max_tokens"] as? Int, maxTokens > 0 {
                session.reportedContextLimit = maxTokens
            }

            if session.contextTokens == nil,
               entry["type"] as? String == "assistant",
               let message = entry["message"] as? [String: Any],
               let usage = message["usage"] as? [String: Any] {
                let input = usage["input_tokens"] as? Int ?? 0
                let cacheRead = usage["cache_read_input_tokens"] as? Int ?? 0
                let cacheWrite = usage["cache_creation_input_tokens"] as? Int ?? 0

                session.contextTokens = input + cacheRead + cacheWrite
                session.model = message["model"] as? String
                if let stamp = entry["timestamp"] as? String {
                    session.lastActivity = ISO8601DateFormatter().date(from: stamp)
                }
            }

            if session.contextTokens != nil, session.reportedContextLimit != nil { return }
        }
    }
}
