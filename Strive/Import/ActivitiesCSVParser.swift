import Foundation

struct ParsedActivityRow {
    var stravaId: String
    var name: String
    var date: Date
    var type: String
    var distanceMeters: Double
    var movingTimeSeconds: Int
    var elapsedTimeSeconds: Int
    var elevationGainMeters: Double
    var filename: String?
}

enum ActivitiesCSVParseError: Error {
    case emptyFile
    case missingColumn(String)
}

/// Parses Strava's `activities.csv`. The schema drifts over the years and
/// the file contains two `Elapsed Time` and two `Distance` columns — the
/// first pair are human-readable strings, the second pair are raw numeric.
/// We prefer the numeric (last) occurrence when available.
struct ActivitiesCSVParser {
    func parse(_ text: String) throws -> [ParsedActivityRow] {
        let rows = CSVReader.parse(text)
        guard let header = rows.first, rows.count > 1 else {
            throw ActivitiesCSVParseError.emptyFile
        }

        let idx = ColumnIndex(header: header)
        try idx.require("Activity ID")
        try idx.require("Activity Type")
        try idx.require("Activity Date")

        var out: [ParsedActivityRow] = []
        out.reserveCapacity(rows.count - 1)

        for r in rows.dropFirst() {
            guard r.count >= header.count else { continue }
            guard let id = idx.first(r, "Activity ID"), !id.isEmpty else { continue }
            let type = idx.first(r, "Activity Type") ?? ""
            guard type == "Run" else { continue }

            let name = idx.first(r, "Activity Name") ?? ""
            let dateStr = idx.first(r, "Activity Date") ?? ""
            guard let date = StravaDate.parse(dateStr) else { continue }

            let distance = idx.numeric(r, "Distance") ?? 0
            let elapsed = idx.numeric(r, "Elapsed Time").map(Int.init) ?? 0
            let moving = idx.numeric(r, "Moving Time").map(Int.init) ?? elapsed
            let elevation = idx.numeric(r, "Elevation Gain") ?? 0
            let filename = idx.first(r, "Filename")

            out.append(ParsedActivityRow(
                stravaId: id,
                name: name,
                date: date,
                type: type,
                distanceMeters: distance,
                movingTimeSeconds: moving,
                elapsedTimeSeconds: elapsed,
                elevationGainMeters: elevation,
                filename: (filename?.isEmpty == false) ? filename : nil
            ))
        }
        return out
    }
}

private struct ColumnIndex {
    let header: [String]
    let byName: [String: [Int]]

    init(header: [String]) {
        self.header = header
        var m: [String: [Int]] = [:]
        for (i, h) in header.enumerated() {
            m[h.trimmingCharacters(in: .whitespaces), default: []].append(i)
        }
        self.byName = m
    }

    func require(_ name: String) throws {
        guard byName[name] != nil else {
            throw ActivitiesCSVParseError.missingColumn(name)
        }
    }

    /// The first occurrence of a column — used for identity / text fields.
    func first(_ row: [String], _ name: String) -> String? {
        guard let i = byName[name]?.first, i < row.count else { return nil }
        return row[i]
    }

    /// Prefer the *last* occurrence when parsing numerics — Strava exports
    /// have both a display string ("5.02") and a raw meters/seconds column
    /// sharing the same header name; the raw one comes second.
    func numeric(_ row: [String], _ name: String) -> Double? {
        guard let indexes = byName[name] else { return nil }
        for i in indexes.reversed() {
            guard i < row.count else { continue }
            let raw = row[i].trimmingCharacters(in: .whitespaces)
            if let v = Double(raw) { return v }
        }
        return nil
    }
}

enum StravaDate {
    /// Strava export dates use en-US style (e.g. "Mar 3, 2024, 10:15:23 AM").
    /// Fall back to ISO-8601 in case a future export changes format.
    static func parse(_ s: String) -> Date? {
        let trimmed = s.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return nil }
        if let d = enUS.date(from: trimmed) { return d }
        return iso.date(from: trimmed)
    }

    private static let enUS: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "MMM d, yyyy, h:mm:ss a"
        return f
    }()

    private static let iso: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
}
