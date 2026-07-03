import Foundation
import SwiftData

@Model
final class RunActivity {
    @Attribute(.unique) var stravaId: String
    var name: String
    var date: Date
    var distanceMeters: Double
    var movingTimeSeconds: Int
    var elapsedTimeSeconds: Int
    var elevationGainMeters: Double
    var averagePaceSecPerKm: Double

    /// Path (relative to the app's documents dir) to the activity's original
    /// FIT / GPX / TCX file once the archive has been extracted. `nil` until
    /// the activity file parser lands.
    var activityFilePath: String?

    @Relationship(deleteRule: .cascade, inverse: \BestSplit.sourceActivity)
    var splits: [BestSplit] = []

    init(
        stravaId: String,
        name: String,
        date: Date,
        distanceMeters: Double,
        movingTimeSeconds: Int,
        elapsedTimeSeconds: Int,
        elevationGainMeters: Double,
        averagePaceSecPerKm: Double,
        activityFilePath: String? = nil
    ) {
        self.stravaId = stravaId
        self.name = name
        self.date = date
        self.distanceMeters = distanceMeters
        self.movingTimeSeconds = movingTimeSeconds
        self.elapsedTimeSeconds = elapsedTimeSeconds
        self.elevationGainMeters = elevationGainMeters
        self.averagePaceSecPerKm = averagePaceSecPerKm
        self.activityFilePath = activityFilePath
    }
}
