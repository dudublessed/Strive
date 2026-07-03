import Foundation

/// A distance-over-time stream sampled from an activity file. Used by the
/// best-split sliding-window algorithm. Times are seconds from activity
/// start; distances are cumulative meters.
struct DistanceStream {
    var times: [Double]
    var distances: [Double]
}

protocol ActivityFileParser {
    func canParse(url: URL) -> Bool
    func parse(url: URL) throws -> DistanceStream
}

/// Chooses a parser by file extension. FIT / GPX / TCX all shipping in v1
/// per project brief.
struct ActivityFileParserRegistry {
    let parsers: [ActivityFileParser]

    static let `default` = ActivityFileParserRegistry(parsers: [
        GPXParser(),
        TCXParser(),
        FITParser()
    ])

    func parser(for url: URL) -> ActivityFileParser? {
        parsers.first { $0.canParse(url: url) }
    }
}

// MARK: - Stubs
// The three parsers below are wired up so the app compiles and the import
// flow can carry files through. The actual stream extraction lands in the
// follow-up commit that introduces BestSplitCalculator.

enum ActivityFileParseError: Error {
    case notImplemented(format: String)
    case malformed(reason: String)
}

struct GPXParser: ActivityFileParser {
    func canParse(url: URL) -> Bool {
        url.pathExtension.lowercased().hasSuffix("gpx")
    }
    func parse(url: URL) throws -> DistanceStream {
        throw ActivityFileParseError.notImplemented(format: "gpx")
    }
}

struct TCXParser: ActivityFileParser {
    func canParse(url: URL) -> Bool {
        url.pathExtension.lowercased().hasSuffix("tcx")
    }
    func parse(url: URL) throws -> DistanceStream {
        throw ActivityFileParseError.notImplemented(format: "tcx")
    }
}

struct FITParser: ActivityFileParser {
    func canParse(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ext == "fit" || ext == "fit.gz"
    }
    func parse(url: URL) throws -> DistanceStream {
        throw ActivityFileParseError.notImplemented(format: "fit")
    }
}
