import AppKit
import Foundation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let statusFeed = StatusFeed()
    private let sessionReader = SessionReader()

    private var snapshot: UsageSnapshot?
    private var sessions: [LiveSession] = []
    private var lastError: String?
    private var refreshTimer: Timer?

    private static let refreshInterval: TimeInterval = 60

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.button?.title = "Claude …"
        rebuildMenu()
        refresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: Self.refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        refreshTimer?.invalidate()
    }

    /// Everything on display is a local file read, so the whole view is rebuilt whenever the menu
    /// is opened and it is always current on screen.
    func menuWillOpen(_ menu: NSMenu) {
        refresh()
    }

    // MARK: - Refresh

    private func refresh() {
        sessions = sessionReader.liveSessions()
        do {
            snapshot = try statusFeed.read()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
        updateTitle()
        rebuildMenu()
    }

    private func updateTitle() {
        guard let snapshot, let headline = snapshot.headline else {
            statusItem.button?.title = "Claude !"
            return
        }
        statusItem.button?.title = "Claude \(headline.remainingPercent)%\(snapshot.isStale ? "?" : "")"
    }

    // MARK: - Menu

    private func rebuildMenu() {
        let menu = NSMenu()
        menu.delegate = self

        addQuotaSection(to: menu)
        menu.addItem(.separator())
        addSessionSection(to: menu)
        menu.addItem(.separator())

        menu.addItem(withTitle: "Refresh Now", action: #selector(refreshNow), keyEquivalent: "r").target = self
        menu.addItem(withTitle: "Copy Summary", action: #selector(copySummary), keyEquivalent: "c").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Claude Usage Menu",
                     action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        statusItem.menu = menu
    }

    private func addQuotaSection(to menu: NSMenu) {
        guard let snapshot else {
            addHeader("Subscription usage", to: menu)
            addDisabled(lastError ?? "Loading…", to: menu)
            return
        }

        addHeader("Subscription usage", to: menu)
        for window in snapshot.windows {
            addDisabled("\(bar(window.utilization))  \(window.title): \(window.remainingPercent)% left", to: menu)
            if let resetsAt = window.resetsAt {
                addDisabled("       resets \(relative(resetsAt))", to: menu)
            }
        }
        // The feed only advances while a session renders its status line, so age is worth stating.
        addDisabled("Read \(relative(snapshot.capturedAt))\(snapshot.isStale ? " — stale" : ""), via statusline", to: menu)
    }

    private func addSessionSection(to menu: NSMenu) {
        guard !sessions.isEmpty else {
            addHeader("No live sessions", to: menu)
            return
        }
        addHeader("Live sessions (\(sessions.count))", to: menu)

        for session in sessions {
            let item = NSMenuItem(title: sessionSummary(session), action: nil, keyEquivalent: "")
            item.submenu = sessionDetail(session)
            menu.addItem(item)
        }

        let total = sessions.compactMap(\.contextTokens).reduce(0, +)
        if total > 0 {
            addDisabled("Combined context: \(tokens(total))", to: menu)
        }
    }

    private func sessionSummary(_ session: LiveSession) -> String {
        guard let used = session.contextTokens, let limit = session.contextLimit,
              let fraction = session.contextFraction
        else {
            return "\(session.label) — context unknown"
        }
        let percent = Int((fraction * 100).rounded())
        return "\(bar(fraction))  \(session.label) — \(percent)% ctx (\(tokens(used))/\(tokens(limit)))"
    }

    private func sessionDetail(_ session: LiveSession) -> NSMenu {
        let detail = NSMenu()
        addDisabled(session.cwd, to: detail)
        if let model = session.model {
            addDisabled("Model: \(model)", to: detail)
        }
        if let used = session.contextTokens, let limit = session.contextLimit {
            let source = session.contextLimitIsReported ? "" : " (window inferred)"
            addDisabled("Context: \(tokens(used)) of \(tokens(limit))\(source)", to: detail)
            addDisabled("Headroom: \(tokens(max(0, limit - used)))", to: detail)
        }
        if let last = session.lastActivity {
            addDisabled("Last turn: \(relative(last))", to: detail)
        }
        addDisabled("Started: \(relative(session.startedAt))", to: detail)
        addDisabled("PID \(session.pid) · \(session.sessionId.prefix(8))", to: detail)
        return detail
    }

    // MARK: - Formatting

    /// Eight-cell meter; reads at a glance in a proportional menu font.
    private func bar(_ fraction: Double) -> String {
        let cells = 8
        let filled = Int((max(0, min(1, fraction)) * Double(cells)).rounded())
        return String(repeating: "▮", count: filled) + String(repeating: "▯", count: cells - filled)
    }

    private func tokens(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        }
        if count >= 1_000 {
            return "\(count / 1_000)K"
        }
        return "\(count)"
    }

    private func relative(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private func addHeader(_ title: String, to menu: NSMenu) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        item.attributedTitle = NSAttributedString(
            string: title,
            attributes: [.font: NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)]
        )
        menu.addItem(item)
    }

    private func addDisabled(_ title: String, to menu: NSMenu) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
    }

    // MARK: - Actions

    @objc private func refreshNow() {
        refresh()
    }

    @objc private func copySummary() {
        var lines: [String] = []
        if let snapshot {
            for window in snapshot.windows {
                var line = "\(window.title): \(window.remainingPercent)% left"
                if let resetsAt = window.resetsAt {
                    line += ", resets \(relative(resetsAt))"
                }
                lines.append(line)
            }
        }
        for session in sessions {
            lines.append(sessionSummary(session).replacingOccurrences(of: "▮", with: "")
                .replacingOccurrences(of: "▯", with: "")
                .trimmingCharacters(in: .whitespaces))
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lines.joined(separator: "\n"), forType: .string)
    }
}
