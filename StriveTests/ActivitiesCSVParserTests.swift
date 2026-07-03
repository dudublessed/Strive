import XCTest
@testable import Strive

final class ActivitiesCSVParserTests: XCTestCase {
    func testParsesRunAndSkipsRide() throws {
        let csv = """
        Activity ID,Activity Date,Activity Name,Activity Type,Elapsed Time,Distance,Elapsed Time,Moving Time,Distance,Elevation Gain,Filename
        123,"Mar 3, 2024, 10:15:23 AM",Morning Run,Run,0:25:00,5.02,1500,1450,5020.5,42.0,activities/123.gpx
        124,"Mar 4, 2024, 08:00:00 AM",Commute,Ride,0:20:00,7.00,1200,1180,7010.0,10.0,activities/124.fit
        125,"Mar 5, 2024, 07:30:12 AM",Trail Run,Trail Run,0:55:00,8.30,3300,3200,8300.0,180.0,activities/125.tcx
        """
        let rows = try ActivitiesCSVParser().parse(csv)
        XCTAssertEqual(rows.count, 1, "only the Run row should survive the type filter")
        let r = rows[0]
        XCTAssertEqual(r.stravaId, "123")
        XCTAssertEqual(r.name, "Morning Run")
        XCTAssertEqual(r.distanceMeters, 5020.5, accuracy: 0.001)
        XCTAssertEqual(r.movingTimeSeconds, 1450)
        XCTAssertEqual(r.elapsedTimeSeconds, 1500)
        XCTAssertEqual(r.elevationGainMeters, 42.0, accuracy: 0.001)
        XCTAssertEqual(r.filename, "activities/123.gpx")
    }

    func testPrefersNumericColumnForDuplicatedHeaders() throws {
        // Strava exports duplicate `Distance` and `Elapsed Time` headers —
        // first is a display string, second is raw numeric. Parser should
        // prefer the numeric occurrence.
        let csv = """
        Activity ID,Activity Date,Activity Type,Elapsed Time,Distance,Elapsed Time,Moving Time,Distance
        1,"Jan 1, 2025, 06:00:00 AM",Run,25:00,5.00,1500,1400,5000.0
        """
        let rows = try ActivitiesCSVParser().parse(csv)
        XCTAssertEqual(rows[0].distanceMeters, 5000.0, accuracy: 0.001)
        XCTAssertEqual(rows[0].elapsedTimeSeconds, 1500)
    }

    func testMissingRequiredColumnThrows() {
        let csv = "Foo,Bar\n1,2\n"
        XCTAssertThrowsError(try ActivitiesCSVParser().parse(csv))
    }
}

final class FormattersTests: XCTestCase {
    func testDurationBelowHour() {
        XCTAssertEqual(Formatters.duration(1450), "24:10")
    }

    func testDurationWithHours() {
        XCTAssertEqual(Formatters.duration(3665), "1:01:05")
    }

    func testDistance() {
        XCTAssertEqual(Formatters.distance(5020.5), "5.02 km")
    }

    func testPace() {
        XCTAssertEqual(Formatters.pace(secPerKm: 272), "4:32 /km")
    }

    func testPaceInvalid() {
        XCTAssertEqual(Formatters.pace(secPerKm: 0), "—")
    }
}
