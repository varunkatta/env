import Foundation

enum UsageAPIError: LocalizedError {
    case noCredential
    case tokenExpired(Date)
    case unauthorized
    case http(Int)
    case unrecognizedShape

    var errorDescription: String? {
        switch self {
        case .noCredential:
            return "No Claude Code sign-in in the Keychain."
        case .tokenExpired(let when):
            let formatter = RelativeDateTimeFormatter()
            return "Sign-in token expired \(formatter.localizedString(for: when, relativeTo: Date())). Any terminal `claude` session renews it."
        case .unauthorized:
            return "The account rejected the stored sign-in token."
        case .http(let code):
            return "Account usage request failed (HTTP \(code))."
        case .unrecognizedShape:
            return "Account usage came back in an unrecognized format. Run with --dump-account."
        }
    }
}

/// Reads subscription usage straight from the account, using the sign-in Claude Code already holds.
///
/// Strictly read-only. The token is read from the Keychain item the `claude` CLI maintains and is
/// never refreshed or written back, so the CLI's credential is never disturbed. When the stored
/// token has expired the client reports that rather than trying to renew it; the next terminal
/// `claude` session renews it as a side effect of its own work.
///
/// The Keychain is read through `/usr/bin/security`, which Claude Code itself uses to write the
/// item, so the read is already on the item's access list and never raises a macOS prompt. Only the
/// read form is used — the token comes back on a pipe, never on a command line.
final class UsageAPI: @unchecked Sendable {
    private let endpoint = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    private let keychainService = "Claude Code-credentials"

    private struct Token {
        let value: String
        let expiresAt: Date
    }

    func fetch() async throws -> UsageSnapshot {
        let data = try await fetchRaw()
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw UsageAPIError.unrecognizedShape
        }
        var windows = Self.windows(from: root)
        guard !windows.isEmpty else { throw UsageAPIError.unrecognizedShape }
        windows.sort { $0.utilization > $1.utilization }
        return UsageSnapshot(windows: windows,
                             capturedAt: Date(),
                             sessionId: nil,
                             source: .account,
                             breakdown: Self.breakdown(from: root))
    }

    func fetchRaw() async throws -> Data {
        let token = try readToken()
        guard token.expiresAt > Date() else { throw UsageAPIError.tokenExpired(token.expiresAt) }

        var request = URLRequest(url: endpoint)
        request.setValue("Bearer \(token.value)", forHTTPHeaderField: "Authorization")
        request.setValue("oauth-2025-04-20", forHTTPHeaderField: "anthropic-beta")
        request.setValue("claude-usage-menu/0.1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        switch (response as? HTTPURLResponse)?.statusCode ?? 0 {
        case 200: return data
        case 401: throw UsageAPIError.unauthorized
        case let code: throw UsageAPIError.http(code)
        }
    }

    // MARK: - Keychain (read only)

    private func readToken() throws -> Token {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        process.arguments = ["find-generic-password", "-s", keychainService, "-w"]
        let output = Pipe()
        process.standardOutput = output
        process.standardError = FileHandle.nullDevice
        try process.run()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard process.terminationStatus == 0,
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauth = root["claudeAiOauth"] as? [String: Any],
              let value = oauth["accessToken"] as? String,
              let expiresAt = oauth["expiresAt"] as? Double
        else { throw UsageAPIError.noCredential }

        return Token(value: value, expiresAt: Date(timeIntervalSince1970: expiresAt / 1000))
    }

    // MARK: - Decoding
    //
    // The account returns a `limits` array, one entry per window:
    //   { kind: "session" | "weekly_all" | "weekly_scoped", percent: 0-100,
    //     resets_at: ISO-8601, scope: { model: { display_name } } | null, is_active, severity }
    // The older top-level `five_hour` / `seven_day` objects (with `utilization` as 0-100) are
    // accepted as a fallback. Every other top-level key is ignored — the response carries a number
    // of internal, codenamed fields that are not windows.

    private static func windows(from root: [String: Any]) -> [UsageWindow] {
        if let limits = root["limits"] as? [[String: Any]] {
            let parsed = limits.compactMap(window(fromLimit:))
            if !parsed.isEmpty { return parsed }
        }
        return legacyWindows(from: root)
    }

    private static func window(fromLimit limit: [String: Any]) -> UsageWindow? {
        guard let percent = limit["percent"] as? Double else { return nil }
        let kind = limit["kind"] as? String ?? limit["group"] as? String ?? "usage"
        let scopedModel = ((limit["scope"] as? [String: Any])?["model"] as? [String: Any])?["display_name"] as? String

        let title: String
        switch kind {
        case "session": title = "5h session"
        case "weekly_all": title = "7d all models"
        case "weekly_scoped": title = "7d \(scopedModel ?? "scoped")"
        default: title = kind.replacingOccurrences(of: "_", with: " ").capitalized
        }
        return UsageWindow(title: title,
                           utilization: percent / 100,
                           resetsAt: StatusFeed.resetDate(in: limit))
    }

    private static func legacyWindows(from root: [String: Any]) -> [UsageWindow] {
        let known: [(key: String, title: String)] = [
            ("five_hour", "5h session"),
            ("seven_day", "7d all models"),
            ("seven_day_opus", "7d Opus"),
            ("seven_day_sonnet", "7d Sonnet"),
        ]
        return known.compactMap { entry in
            guard let object = root[entry.key] as? [String: Any],
                  let utilization = object["utilization"] as? Double
            else { return nil }
            return UsageWindow(title: entry.title,
                               utilization: utilization / 100,
                               resetsAt: StatusFeed.resetDate(in: object))
        }
    }

    /// `seven_day_breakdown.rows` attributes the weekly window to surfaces (Claude Code, Chats…).
    private static func breakdown(from root: [String: Any]) -> [BreakdownRow] {
        guard let block = root["seven_day_breakdown"] as? [String: Any],
              let rows = block["rows"] as? [[String: Any]]
        else { return [] }
        return rows.compactMap { row in
            guard let name = row["display_name"] as? String,
                  let percent = row["percent"] as? Double
            else { return nil }
            return BreakdownRow(name: name, percent: Int(percent.rounded()))
        }
        .filter { $0.percent > 0 }
    }
}
