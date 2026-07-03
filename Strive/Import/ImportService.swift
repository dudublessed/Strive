import Foundation
import SwiftData

@MainActor
final class ImportService {
    struct Summary {
        var inserted: Int
        var updated: Int
        var skippedNonRun: Int
    }

    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Import from a directory containing (at any depth) an `activities.csv`.
    /// Accepts an unzipped export or the ZIP-extracted staging directory.
    func importExport(from directory: URL) throws -> Summary {
        guard let csvURL = ArchiveExtractor.locateActivitiesCSV(in: directory) else {
            throw ImportError.missingActivitiesCSV
        }
        let text = try String(contentsOf: csvURL, encoding: .utf8)
        let rows = try ActivitiesCSVParser().parse(text)
        return try upsert(rows: rows)
    }

    /// Import directly from a CSV file (dev convenience — the same code path
    /// as `importExport`, minus the enumeration).
    func importCSV(from url: URL) throws -> Summary {
        let text = try String(contentsOf: url, encoding: .utf8)
        let rows = try ActivitiesCSVParser().parse(text)
        return try upsert(rows: rows)
    }

    private func upsert(rows: [ParsedActivityRow]) throws -> Summary {
        var inserted = 0
        var updated = 0

        for row in rows {
            let id = row.stravaId
            var descriptor = FetchDescriptor<RunActivity>(
                predicate: #Predicate { $0.stravaId == id }
            )
            descriptor.fetchLimit = 1
            let existing = try context.fetch(descriptor).first

            let pace = row.movingTimeSeconds > 0 && row.distanceMeters > 0
                ? Double(row.movingTimeSeconds) / (row.distanceMeters / 1_000)
                : 0

            if let a = existing {
                a.name = row.name
                a.date = row.date
                a.distanceMeters = row.distanceMeters
                a.movingTimeSeconds = row.movingTimeSeconds
                a.elapsedTimeSeconds = row.elapsedTimeSeconds
                a.elevationGainMeters = row.elevationGainMeters
                a.averagePaceSecPerKm = pace
                a.activityFilePath = row.filename
                updated += 1
            } else {
                let a = RunActivity(
                    stravaId: row.stravaId,
                    name: row.name,
                    date: row.date,
                    distanceMeters: row.distanceMeters,
                    movingTimeSeconds: row.movingTimeSeconds,
                    elapsedTimeSeconds: row.elapsedTimeSeconds,
                    elevationGainMeters: row.elevationGainMeters,
                    averagePaceSecPerKm: pace,
                    activityFilePath: row.filename
                )
                context.insert(a)
                inserted += 1
            }
        }
        try context.save()

        return Summary(inserted: inserted, updated: updated, skippedNonRun: 0)
    }
}

enum ImportError: Error, LocalizedError {
    case missingActivitiesCSV

    var errorDescription: String? {
        switch self {
        case .missingActivitiesCSV:
            return "Couldn't find activities.csv in the selected folder."
        }
    }
}
