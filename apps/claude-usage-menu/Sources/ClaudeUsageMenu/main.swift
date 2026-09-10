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

/// `--dump-usage` prints the cached quota reading and exits, for checking that the statusline hook
/// is feeding the app.
if CommandLine.arguments.contains("--dump-usage") {
    do {
        let snapshot = try StatusFeed().read()
        print("captured \(snapshot.capturedAt)\(snapshot.isStale ? " (stale)" : "")")
        for window in snapshot.windows {
            let resets = window.resetsAt.map { ", resets \($0)" } ?? ""
            print("\(window.title): \(window.remainingPercent)% left\(resets)")
        }
        exit(0)
    } catch {
        FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
        exit(1)
    }
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
