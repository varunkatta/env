import AppKit
import Foundation
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let usageAPI = UsageAPI()
    private let statusFeed = StatusFeed()
    private let sessionReader = SessionReader()

    /// The newest successful account read. Kept when a later read fails, so a passing network
    /// blip does not blank the label; it ages out like any other reading.
    private var accountSnapshot: UsageSnapshot?
    private var feedSnapshot: UsageSnapshot?
    private var sessions: [LiveSession] = []
    /// Why the latest account read failed, shown so an older reading is never mistaken for live.
    private var accountError: String?
    private var feedError: String?
    private var fetchTask: Task<Void, Never>?
    private var refreshTimer: Timer?
    private var lastRefresh: Date?
    private var menuIsOpen = false

    private static let refreshInterval: TimeInterval = 60
    /// An account reading counts as live while it is younger than this.
    private static let liveWindow: TimeInterval = 3 * refreshInterval
    /// At or below this much left, the label turns amber and shows when the window resets.
    private static let warnRemaining = 25
    /// At or below this much left, the label turns red.
    private static let criticalRemaining = 10

    func applicationDidFinishLaunching(_ notification: Notification) {
        menu.delegate = self
        menu.autoenablesItems = false
        statusItem.menu = menu
        statusItem.button?.title = "Claude …"
        statusItem.button?.toolTip = "Claude Usage Menu"

        refresh()

        let timer = Timer(timeInterval: Self.refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        timer.tolerance = 5
        // Common modes keep the timer firing while the menu is open.
        RunLoop.main.add(timer, forMode: .common)
        refreshTimer = timer

        // A sleeping Mac skips timer fires; read straight away on wake instead of showing an
        // hours-old number for up to a minute.
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        refreshTimer?.invalidate()
        fetchTask?.cancel()
    }

    /// The local parts are re-read whenever the menu opens so they are current on screen; the
    /// account read is left to the timer because it is a network round trip. The open menu is
    /// filled in place: assigning a new menu here would only take effect on the next open.
    func menuWillOpen(_ menu: NSMenu) {
        guard menu === self.menu else { return }
        menuIsOpen = false
        readLocal()
        updateTitle()
        populateMenu()
        menuIsOpen = true
    }

    func menuDidClose(_ menu: NSMenu) {
        guard menu === self.menu else { return }
        menuIsOpen = false
        // Catch up on anything a background refresh held back while the menu was on screen.
        populateMenu()
    }

    // MARK: - Refresh

    /// Sources are layered: the account read is live whenever the stored sign-in is usable; the
    /// statusline feed stands in when it is not; and when neither is fresh the label drops the
    /// number rather than show a dead one.
    private func refresh() {
        lastRefresh = Date()
        readLocal()
        updateTitle()
        populateMenu()

        // One account read at a time; a slow response must not land after a newer one.
        guard fetchTask == nil else { return }
        fetchTask = Task { [usageAPI] in
            let result: Result<UsageSnapshot, Error>
            do {
                result = .success(try await usageAPI.fetch())
            } catch {
                result = .failure(error)
            }
            self.finishFetch(result)
        }
    }

    private func finishFetch(_ result: Result<UsageSnapshot, Error>) {
        fetchTask = nil
        switch result {
        case .success(let snapshot):
            accountSnapshot = snapshot
            accountError = nil
        case .failure(let error):
            accountError = error.localizedDescription
        }
        updateTitle()
        populateMenu()
    }

    private func readLocal() {
        sessions = sessionReader.liveSessions()
        do {
            feedSnapshot = try statusFeed.read()
            feedError = nil
        } catch {
            feedSnapshot = nil
            feedError = error.localizedDescription
        }
    }

    /// The freshest reading from either source.
    private var snapshot: UsageSnapshot? {
        [accountSnapshot, feedSnapshot].compactMap { $0 }.max { $0.capturedAt < $1.capturedAt }
    }

    private func isLive(_ snapshot: UsageSnapshot) -> Bool {
        snapshot.source == .account && Date().timeIntervalSince(snapshot.capturedAt) < Self.liveWindow
    }

    private func updateTitle() {
        guard let button = statusItem.button else { return }
        guard let snapshot, let headline = snapshot.headline, !snapshot.isStale else {
            button.attributedTitle = NSAttributedString(string: "Claude", attributes: [.font: Self.titleFont])
            button.toolTip = "Claude usage unavailable — open the menu for the reason"
            return
        }

        let remaining = headline.remainingPercent
        var text = "Claude \(remaining)%"
        if remaining <= Self.warnRemaining, let resetsAt = headline.resetsAt {
            text += " · \(Self.countdown(to: resetsAt))"
        }

        var attributes: [NSAttributedString.Key: Any] = [.font: Self.titleFont]
        if remaining <= Self.criticalRemaining {
            attributes[.foregroundColor] = NSColor.systemRed
        } else if remaining <= Self.warnRemaining {
            attributes[.foregroundColor] = NSColor.systemOrange
        }
        button.attributedTitle = NSAttributedString(string: text, attributes: attributes)

        var tip = "\(headline.title): \(remaining)% left"
        if let resetsAt = headline.resetsAt { tip += ", resets \(Self.resetText(resetsAt))" }
        button.toolTip = tip
    }

    /// Monospaced digits keep the label from shifting width as the number changes.
    private static var titleFont: NSFont {
        NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
    }

    // MARK: - Menu

    /// Rebuilding while the menu is on screen would collapse an open session submenu, so a
    /// background refresh only updates the label then; the menu catches up when it closes.
    private func populateMenu() {
        if menuIsOpen { return }
        menu.removeAllItems()

        addQuotaSection()
        menu.addItem(.separator())
        addSessionSection()
        menu.addItem(.separator())

        addAction("Refresh Now", #selector(refreshNow), key: "r")
        addAction("Copy Summary", #selector(copySummary), key: "c")
        menu.addItem(.separator())

        let login = addAction("Launch at Login", #selector(toggleLaunchAtLogin), key: "")
        switch SMAppService.mainApp.status {
        case .enabled: login.state = .on
        case .requiresApproval: login.state = .mixed
        default: login.state = .off
        }

        let quit = NSMenuItem(title: "Quit Claude Usage Menu",
                              action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quit)
    }

    private func addQuotaSection() {
        addHeader("Subscription usage", to: menu)

        guard let snapshot else {
            addDisabled(lastRefresh == nil || (fetchTask != nil && accountError == nil) ? "Loading…" : "No reading available", to: menu)
            if let accountError { addDisabled("Account: \(accountError)", to: menu) }
            if let feedError { addDisabled("Statusline: \(feedError)", to: menu) }
            return
        }

        for window in snapshot.windows {
            addDisabled("\(bar(window.utilization))  \(window.title): \(window.remainingPercent)% left", to: menu)
            if let resetsAt = window.resetsAt {
                addDisabled("       resets \(Self.resetText(resetsAt))", to: menu)
            }
        }

        if !snapshot.breakdown.isEmpty {
            let shares = snapshot.breakdown.map { "\($0.name) \($0.percent)%" }.joined(separator: " · ")
            addDisabled("7d usage by surface: \(shares)", to: menu)
        }

        // Only a recent account read is live; anything else is a snapshot whose age matters.
        let age = isLive(snapshot) ? "Live" : "Read \(Self.relative(snapshot.capturedAt))"
        addDisabled("\(age)\(snapshot.isStale ? " — stale" : ""), via \(snapshot.source.label)", to: menu)
        if let accountError {
            addDisabled("Account: \(accountError)", to: menu)
        }
    }

    private func addSessionSection() {
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
        detail.autoenablesItems = false
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
            addDisabled("Last turn: \(Self.relative(last))", to: detail)
        }
        if let started = session.startedAt {
            addDisabled("Started: \(Self.relative(started))", to: detail)
        }
        addDisabled("PID \(session.pid) · \(session.sessionId.prefix(8))", to: detail)

        detail.addItem(.separator())
        let reveal = NSMenuItem(title: "Show Folder in Finder", action: #selector(revealFolder(_:)), keyEquivalent: "")
        reveal.target = self
        reveal.representedObject = session.cwd
        detail.addItem(reveal)

        let resume = NSMenuItem(title: "Copy Resume Command", action: #selector(copyText(_:)), keyEquivalent: "")
        resume.target = self
        resume.representedObject = "cd \(Self.shellQuoted(session.cwd)) && claude --resume \(session.sessionId)"
        detail.addItem(resume)
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

    private static func relative(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// "in 3 hours (Thu 2:00 PM)": the countdown for planning, the clock time for certainty.
    private static func resetText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate(
            Calendar.current.isDateInToday(date) ? "jmm" : "EEEjmm"
        )
        return "\(relative(date)) (\(formatter.string(from: date)))"
    }

    /// Compact time left for the menu bar label: "2h 05m", "45m".
    private static func countdown(to date: Date) -> String {
        let minutes = max(0, Int(date.timeIntervalSinceNow / 60))
        if minutes >= 24 * 60 { return "\(minutes / (24 * 60))d \((minutes / 60) % 24)h" }
        if minutes >= 60 { return String(format: "%dh %02dm", minutes / 60, minutes % 60) }
        return "\(minutes)m"
    }

    private static func shellQuoted(_ text: String) -> String {
        "'" + text.replacingOccurrences(of: "'", with: "'\\''") + "'"
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

    @discardableResult
    private func addAction(_ title: String, _ action: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        menu.addItem(item)
        return item
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
                    line += ", resets \(Self.resetText(resetsAt))"
                }
                lines.append(line)
            }
            let age = isLive(snapshot) ? "live" : "read \(Self.relative(snapshot.capturedAt))"
            lines.append("(\(age), via \(snapshot.source.label))")
        } else {
            lines.append("Subscription usage: unavailable")
        }
        for session in sessions {
            lines.append(sessionSummary(session).replacingOccurrences(of: "▮", with: "")
                .replacingOccurrences(of: "▯", with: "")
                .trimmingCharacters(in: .whitespaces))
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lines.joined(separator: "\n"), forType: .string)
    }

    @objc private func revealFolder(_ sender: NSMenuItem) {
        guard let path = sender.representedObject as? String else { return }
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: path)
    }

    @objc private func copyText(_ sender: NSMenuItem) {
        guard let text = sender.representedObject as? String else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    /// Registers the running bundle as a login item. Only works from the built `.app`; `swift run`
    /// has no bundle to register, and the error says so.
    @objc private func toggleLaunchAtLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
                if service.status == .requiresApproval {
                    SMAppService.openSystemSettingsLoginItems()
                }
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not change Launch at Login"
            alert.informativeText = "\(error.localizedDescription)\n\nLaunch at Login works only when running the built ClaudeUsageMenu.app, not `swift run`."
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
        populateMenu()
    }
}
