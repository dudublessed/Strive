import Foundation

/// Sliding-window best-split extractor. Given a monotonic distance stream,
/// returns the fastest continuous window covering `targetMeters`, or `nil`
/// if the run is too short.
///
/// The implementation lands with the FIT/GPX/TCX parsers in the follow-up
/// commit — the interface is here so the rest of the app can compile
/// against it now.
struct BestSplitCalculator {
    func bestSplit(
        in stream: DistanceStream,
        targetMeters: Double
    ) -> BestSplitResult? {
        // TODO: implement sliding window over stream.distances / stream.times
        // with linear interpolation at the window boundaries. Land alongside
        // the actual GPX/TCX/FIT parsers.
        _ = stream
        _ = targetMeters
        return nil
    }
}

struct BestSplitResult {
    var durationSeconds: Double
    var startIndex: Int
    var endIndex: Int
}
