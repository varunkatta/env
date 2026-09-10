import Foundation

/// One rate-limit window reported by the account, e.g. the rolling 5-hour or 7-day allowance.
struct UsageWindow {
    let key: String
    let utilization: Double // Fraction of the allowance consumed, 0...1.
    let resetsAt: Date?

    var remainingPercent: Int {
        Int((max(0, min(1, 1 - utilization)) * 100).rounded())
    }

    /// Claude Code labels these windows `5h` and `7d`; the rest are spelled out.
    var title: String {
        switch key {
        case "five_hour": return "5h window"
        case "seven_day": return "7d window"
        case "seven_day_opus": return "7d Opus"
        case "seven_day_sonnet": return "7d Sonnet"
        case "seven_day_overage_included": return "7d incl. overage"
        case "overage": return "Overage"
        default:
            return key.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

struct UsageSnapshot {
    let windows: [UsageWindow]
    let capturedAt: Date
    let sessionId: String?

    /// The window the menu bar label tracks: whichever is closest to exhaustion.
    var headline: UsageWindow? {
        windows.max { $0.utilization < $1.utilization }
    }

    /// The feed is only refreshed while a Claude Code session is on screen, so age matters.
    var isStale: Bool {
        Date().timeIntervalSince(capturedAt) > 30 * 60
    }
}

enum StatusFeedError: LocalizedError {
    case missing
    case unreadable

    var errorDescription: String? {
        switch self {
        case .missing:
            return "No quota reading yet — see README to install the statusline hook."
        case .unreadable:
            return "The cached quota reading could not be parsed."
        }
    }
}

/// Reads the quota snapshot that the statusline hook caches to disk.
///
/// Claude Code hands its statusline command a JSON payload that includes the account's
/// `rate_limits`. The hook writes that straight to a file, so this app can show real quota numbers
/// without touching credentials, the Keychain, or the network.
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
                  let utilization = Self.utilization(in: window)
            else { continue }
            windows.append(UsageWindow(key: key,
                                       utilization: utilization,
                                       resetsAt: Self.resetDate(in: window)))
        }
        guard !windows.isEmpty else { throw StatusFeedError.missing }

        // Most-consumed first, so the window that will bite is at the top.
        windows.sort { $0.utilization > $1.utilization }
        return UsageSnapshot(windows: windows,
                             capturedAt: capturedAt,
                             sessionId: root["session_id"] as? String)
    }

    // MARK: - Field lookup
    //
    // Claude Code documents each window as `used_percentage` (0-100) plus `resets_at` (Unix epoch
    // seconds). The alternatives are accepted defensively. Scale is decided by the key name rather
    // than the magnitude, so a genuine `used_percentage` of 0.5 reads as half a percent, not half.

    private static let percentageKeys = ["used_percentage", "used_percent", "usedPercent", "percent_used"]
    private static let fractionKeys = ["utilization"]
    private static let resetKeys = ["resets_at", "resetsAt", "reset_at", "resetAt"]

    private static func utilization(in window: [String: Any]) -> Double? {
        for key in percentageKeys {
            if let value = window[key] as? Double { return value / 100 }
        }
        for key in fractionKeys {
            if let value = window[key] as? Double { return value }
        }
        return nil
    }

    private static func resetDate(in window: [String: Any]) -> Date? {
        for key in resetKeys {
            if let text = window[key] as? String {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let parsed = formatter.date(from: text) { return parsed }
                formatter.formatOptions = [.withInternetDateTime]
                if let parsed = formatter.date(from: text) { return parsed }
            }
            if let seconds = window[key] as? Double, seconds > 0 {
                return Date(timeIntervalSince1970: seconds > 1e11 ? seconds / 1000 : seconds)
            }
        }
        return nil
    }
}
