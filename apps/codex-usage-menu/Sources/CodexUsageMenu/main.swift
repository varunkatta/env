import AppKit
import Foundation

private enum UsageBridgeError: LocalizedError {
    case codexNotFound
    case timedOut
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .codexNotFound:
            return "Could not find the Codex binary bundled with ChatGPT Desktop."
        case .timedOut:
            return "Codex did not return usage data within 10 seconds."
        case .malformedResponse:
            return "Codex returned usage data in an unexpected format."
        }
    }
}

private struct JSONRPCEnvelope: Decodable {
    let id: Int?
    let result: UsageResult?
}

private struct UsageResult: Decodable {
    let rateLimits: RateLimit
    let rateLimitsByLimitId: [String: RateLimit]?
    let rateLimitResetCredits: ResetCredits?
}

private struct RateLimit: Decodable {
    let limitId: String?
    let limitName: String?
    let primary: RateLimitWindow?
    let secondary: RateLimitWindow?
    let credits: Credits?
    let individualLimit: SpendControl?
    let planType: String?
    let rateLimitReachedType: String?
    let spendControlReached: Bool?
}

private struct RateLimitWindow: Decodable {
    let usedPercent: Int
    let resetsAt: Int?
    let windowDurationMins: Int?
}

private struct Credits: Decodable {
    let balance: String?
    let hasCredits: Bool
    let unlimited: Bool
}

private struct SpendControl: Decodable {
    let limit: String
    let used: String
    let remainingPercent: Int
    let resetsAt: Int
}

private struct ResetCredits: Decodable {
    let availableCount: Int
}

private struct UsageSnapshot {
    let plan: String?
    let limits: [RateLimit]
    let resetCredits: Int

    static func from(_ result: UsageResult) -> UsageSnapshot {
        let allLimits = result.rateLimitsByLimitId.map { values in
            values.values.sorted { ($0.limitName ?? $0.limitId ?? "") < ($1.limitName ?? $1.limitId ?? "") }
        } ?? [result.rateLimits]
        return UsageSnapshot(
            plan: result.rateLimits.planType,
            limits: allLimits,
            resetCredits: result.rateLimitResetCredits?.availableCount ?? 0
        )
    }
}

private final class CodexUsageBridge: @unchecked Sendable {
    private static let bundledCodex = "/Applications/ChatGPT.app/Contents/Resources/codex"

    func fetch() async throws -> UsageSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    continuation.resume(returning: try self.fetchSynchronously())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func fetchSynchronously() throws -> UsageSnapshot {
        guard FileManager.default.isExecutableFile(atPath: Self.bundledCodex) else {
            throw UsageBridgeError.codexNotFound
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: Self.bundledCodex)
        process.arguments = ["app-server"]

        let input = Pipe()
        let output = Pipe()
        let errors = Pipe()
        process.standardInput = input
        process.standardOutput = output
        process.standardError = errors
        try process.run()

        defer {
            if process.isRunning {
                process.terminate()
            }
        }

        let requests = [
            #"{"id":1,"method":"initialize","params":{"clientInfo":{"name":"codex-usage-menu","version":"0.1.0"}}}"#,
            #"{"id":2,"method":"account/rateLimits/read","params":null}"#,
        ].joined(separator: "\n") + "\n"
        input.fileHandleForWriting.write(Data(requests.utf8))

        var buffered = Data()
        let deadline = Date().addingTimeInterval(10)
        while Date() < deadline {
            let data = output.fileHandleForReading.availableData
            guard !data.isEmpty else { break }
            buffered.append(data)

            while let newline = buffered.firstIndex(of: 0x0A) {
                let line = Data(buffered.prefix(upTo: newline))
                buffered.removeSubrange(...newline)
                guard !line.isEmpty else { continue }
                guard let envelope = try? JSONDecoder().decode(JSONRPCEnvelope.self, from: line) else {
                    continue // Notifications do not need to be understood by this read-only client.
                }
                if envelope.id == 2, let result = envelope.result {
                    return UsageSnapshot.from(result)
                }
            }
        }

        if !process.isRunning {
            let errorText = String(data: errors.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            if !errorText.isEmpty {
                throw NSError(domain: "CodexUsageMenu", code: 1, userInfo: [NSLocalizedDescriptionKey: errorText])
            }
        }
        throw UsageBridgeError.timedOut
    }
}

@MainActor
private final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let bridge = CodexUsageBridge()
    private var snapshot: UsageSnapshot?
    private var lastError: String?
    private var refreshTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem.button?.title = "Codex …"
        statusItem.menu = makeMenu()
        refresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        refreshTimer?.invalidate()
    }

    private func refresh() {
        statusItem.button?.title = "Codex …"
        Task {
            do {
                snapshot = try await bridge.fetch()
                lastError = nil
            } catch {
                lastError = error.localizedDescription
            }
            updateStatusTitle()
            statusItem.menu = makeMenu()
        }
    }

    private func updateStatusTitle() {
        guard let snapshot, let primary = snapshot.limits.first(where: { $0.limitId == "codex" })?.primary ?? snapshot.limits.first?.primary else {
            statusItem.button?.title = "Codex !"
            return
        }
        statusItem.button?.title = "Codex \(max(0, 100 - primary.usedPercent))%"
    }

    private func makeMenu() -> NSMenu {
        let menu = NSMenu()
        if let snapshot {
            let plan = snapshot.plan?.capitalized ?? "Unknown plan"
            addDisabled("Codex usage — \(plan)", to: menu)
            menu.addItem(.separator())
            for limit in snapshot.limits {
                addLimit(limit, to: menu)
            }
            if snapshot.resetCredits > 0 {
                addDisabled("Reset credits available: \(snapshot.resetCredits)", to: menu)
            }
            menu.addItem(.separator())
            addDisabled("Refreshes every 60 seconds", to: menu)
        } else {
            addDisabled("Usage unavailable", to: menu)
            if let lastError { addDisabled(lastError, to: menu) }
        }
        menu.addItem(.separator())
        menu.addItem(withTitle: "Refresh Now", action: #selector(refreshNow), keyEquivalent: "r").target = self
        menu.addItem(withTitle: "Copy Summary", action: #selector(copySummary), keyEquivalent: "c").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Codex Usage Menu", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        return menu
    }

    private func addLimit(_ limit: RateLimit, to menu: NSMenu) {
        let name = limit.limitName ?? limit.limitId ?? "Codex"
        if let primary = limit.primary {
            addDisabled("\(name): \(100 - primary.usedPercent)% remaining — \(resetText(primary))", to: menu)
        }
        if let secondary = limit.secondary {
            addDisabled("  Secondary: \(100 - secondary.usedPercent)% remaining — \(resetText(secondary))", to: menu)
        }
        if let credits = limit.credits, credits.hasCredits {
            addDisabled("  Credits: \(credits.unlimited ? "unlimited" : (credits.balance ?? "available"))", to: menu)
        }
        if let control = limit.individualLimit {
            addDisabled("  Spend control: \(control.remainingPercent)% remaining", to: menu)
        }
        if let reached = limit.rateLimitReachedType {
            addDisabled("  Limit status: \(reached)", to: menu)
        }
    }

    private func resetText(_ window: RateLimitWindow) -> String {
        guard let timestamp = window.resetsAt else { return "reset unavailable" }
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return "resets \(formatter.localizedString(for: date, relativeTo: Date()))"
    }

    private func addDisabled(_ title: String, to menu: NSMenu) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
    }

    @objc private func refreshNow() {
        refresh()
    }

    @objc private func copySummary() {
        guard let snapshot else { return }
        let lines = snapshot.limits.compactMap { limit -> String? in
            guard let window = limit.primary else { return nil }
            let name = limit.limitName ?? limit.limitId ?? "Codex"
            return "\(name): \(100 - window.usedPercent)% remaining, \(resetText(window))"
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(lines.joined(separator: "\n"), forType: .string)
    }
}

let application = NSApplication.shared
private let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()
