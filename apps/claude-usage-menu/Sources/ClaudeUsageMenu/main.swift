import AppKit
import Foundation

/// `--dump-sessions` prints the live-session view and exits, for checking the local half of the app
/// in isolation.
if CommandLine.arguments.contains("--dump-sessions") {
    let sessions = SessionReader().liveSessions()
    if sessions.isEmpty {
        print("no live sessions")
    }
    for session in sessions {
        let context = session.contextTokens.map(String.init) ?? "unknown"
        let limit = session.contextLimit.map(String.init) ?? "unknown"
        let percent = session.contextFraction.map { "\(Int(($0 * 100).rounded()))%" } ?? "—"
        print("\(session.label)  ctx=\(context)/\(limit) (\(percent))  model=\(session.model ?? "?")  pid=\(session.pid)")
        print("    \(session.cwd)")
    }
    exit(0)
}

/// `--dump-account` prints the raw account usage response and exits. It prints usage data only,
/// never the token, and is how the response shape gets inspected when a window is unrecognised.
if CommandLine.arguments.contains("--dump-account") {
    // Detached so the work does not inherit the MainActor that `dispatchMain()` parks on.
    Task.detached {
        do {
            let data = try await UsageAPI().fetchRaw()
            let object = try JSONSerialization.jsonObject(with: data)
            let pretty = try JSONSerialization.data(withJSONObject: object,
                                                    options: [.prettyPrinted, .sortedKeys])
            print(String(data: pretty, encoding: .utf8) ?? "")
            exit(0)
        } catch {
            FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
            exit(1)
        }
    }
    dispatchMain()
}

/// `--dump-usage` prints the quota reading the app would show — account first, statusline as the
/// fallback — and exits.
if CommandLine.arguments.contains("--dump-usage") {
    Task.detached {
        let snapshot: UsageSnapshot
        do {
            snapshot = try await UsageAPI().fetch()
        } catch {
            print("account unavailable: \(error.localizedDescription)")
            do {
                snapshot = try StatusFeed().read()
            } catch {
                FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
                exit(1)
            }
        }
        print("via \(snapshot.source.label), captured \(snapshot.capturedAt)\(snapshot.isStale ? " (stale)" : "")")
        for window in snapshot.windows {
            let resets = window.resetsAt.map { ", resets \($0)" } ?? ""
            print("\(window.title): \(window.remainingPercent)% left\(resets)")
        }
        exit(0)
    }
    dispatchMain()
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
