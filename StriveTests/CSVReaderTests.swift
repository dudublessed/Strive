import XCTest
@testable import Strive

final class CSVReaderTests: XCTestCase {
    func testSimpleRows() {
        let rows = CSVReader.parse("a,b,c\n1,2,3\n")
        XCTAssertEqual(rows, [["a", "b", "c"], ["1", "2", "3"]])
    }

    func testQuotedFieldWithComma() {
        let rows = CSVReader.parse("name,note\n\"Doe, John\",hi\n")
        XCTAssertEqual(rows, [["name", "note"], ["Doe, John", "hi"]])
    }

    func testEscapedQuote() {
        let rows = CSVReader.parse("a\n\"He said \"\"hi\"\"\"\n")
        XCTAssertEqual(rows, [["a"], ["He said \"hi\""]])
    }

    func testEmbeddedNewlineInQuotes() {
        let rows = CSVReader.parse("a,b\n\"line1\nline2\",x\n")
        XCTAssertEqual(rows, [["a", "b"], ["line1\nline2", "x"]])
    }

    func testTrailingRowWithoutNewline() {
        let rows = CSVReader.parse("a,b\n1,2")
        XCTAssertEqual(rows, [["a", "b"], ["1", "2"]])
    }
}
