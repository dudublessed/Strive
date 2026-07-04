import Foundation
import SwiftData

/// A best-effort split extracted from one activity. There's at most one row
/// per (activity, distance) — the dashboard picks the fastest across all rows.
@Model
final class BestSplit {
    var distanceLabel: String
    var targetMeters: Double
    var durationSeconds: Double
    var date: Date
    var sourceActivityId: String
    var sourceActivity: RunActivity?

    init(
        distanceLabel: String,
        targetMeters: Double,
        durationSeconds: Double,
        date: Date,
        sourceActivityId: String,
        sourceActivity: RunActivity? = nil
    ) {
        self.distanceLabel = distanceLabel
        self.targetMeters = targetMeters
        self.durationSeconds = durationSeconds
        self.date = date
        self.sourceActivityId = sourceActivityId
        self.sourceActivity = sourceActivity
    }
}

enum SplitDistance: CaseIterable {
    case fiveK
    case tenK
    case halfMarathon

    var meters: Double {
        switch self {
        case .fiveK: return 5_000
        case .tenK: return 10_000
        case .halfMarathon: return 21_097.5
        }
    }

    var label: String {
        switch self {
        case .fiveK: return "5 km"
        case .tenK: return "10 km"
        case .halfMarathon: return "Meia maratona"
        }
    }
}
