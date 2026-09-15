import Foundation

/// One rate-limit window, e.g. the rolling 5-hour session allowance or a weekly cap.
struct UsageWindow {
    let title: String
    /// Fraction of the allowance consumed, 0...1.
    let utilization: Double
    let resetsAt: Date?

    var remainingPercent: Int {
        Int((max(0, min(1, 1 - utilization)) * 100).rounded())
    }
}

/// A share of a window attributed to one surface, e.g. Claude Code vs Chats.
struct BreakdownRow {
    let name: String
    let percent: Int
}

struct UsageSnapshot {
    enum Source {
        case account, statusline

        var label: String {
            switch self {
            case .account: return "account"
            case .statusline: return "statusline"
            }
        }
    }

    let windows: [UsageWindow]
    let capturedAt: Date
    let sessionId: String?
    let source: Source
    let breakdown: [BreakdownRow]

    /// The window the menu bar label tracks: whichever is closest to exhaustion.
    var headline: UsageWindow? {
        windows.max { $0.utilization < $1.utilization }
    }

    /// A statusline reading only advances while a session renders, so age matters. An account
    /// reading is fetched on the spot and is never stale.
    var isStale: Bool {
        source != .account && Date().timeIntervalSince(capturedAt) > 30 * 60
    }
}

enum StatusFeedError: LocalizedError {
    case missing
    case unreadable

    var errorDescription: String? {
        switch self {
        case .missing: return "No statusline reading cached."
        case .unreadable: return "The cached statusline reading could not be parsed."
        }
    }
}

/// Reads the quota snapshot that the statusline hook caches to disk.
///
/// Claude Code hands its statusline command a `rate_limits` block documenting each window as
/// `used_percentage` (0-100) plus `resets_at` (Unix epoch seconds). This is the fallback source,
/// used when the account cannot be read.
struct StatusFeed {
    static let path = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".claude/usage-menu/status.json")

    func read() throws -> UsageSnapshot {
        guard let data = try? Data(contentsOf: Self.path) else { throw StatusFeedError.missing }
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw StatusFeedError.unreadable
        }

        let capturedAt = (root["captured_at"] as? Double).map { Date(timeIntervalSince1970: $0) } ?? .distantPast
        let limits = root["rate_limits"] as? [String: Any] ?? [:]

        var windows: [UsageWindow] = []
        for (key, value) in limits {
            guard let window = value as? [String: Any],
                  let percentage = Self.usedPercentage(in: window)
            else { continue }
            windows.append(UsageWindow(title: Self.title(for: key),
                                       utilization: percentage / 100,
                                       resetsAt: Self.resetDate(in: window)))
        }
        guard !windows.isEmpty else { throw StatusFeedError.missing }

        windows.sort { $0.utilization > $1.utilization }
        return UsageSnapshot(windows: windows,
                             capturedAt: capturedAt,
                             sessionId: root["session_id"] as? String,
                             source: .statusline,
                             breakdown: [])
    }

    /// Claude Code documents `used_percentage` (0-100); the others are accepted defensively.
    private static func usedPercentage(in window: [String: Any]) -> Double? {
        for key in ["used_percentage", "used_percent", "usedPercent", "percent_used", "percent"] {
            if let value = window[key] as? Double { return value }
        }
        return nil
    }

    private static func title(for key: String) -> String {
        switch key {
        case "five_hour": return "5h session"
        case "seven_day": return "7d all models"
        case "seven_day_opus": return "7d Opus"
        case "seven_day_sonnet": return "7d Sonnet"
        case "seven_day_overage_included": return "7d incl. overage"
        default: return key.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    /// `resets_at` is Unix epoch seconds in the statusline contract; ISO-8601 is accepted too.
    static func resetDate(in window: [String: Any]) -> Date? {
        for key in ["resets_at", "resetsAt", "reset_at", "resetAt"] {
            if let text = window[key] as? String, let parsed = parseISO(text) { return parsed }
            if let seconds = window[key] as? Double, seconds > 0 {
                return Date(timeIntervalSince1970: seconds > 1e11 ? seconds / 1000 : seconds)
            }
        }
        return nil
    }

    static func parseISO(_ text: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let parsed = formatter.date(from: text) { return parsed }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: text)
    }
}
