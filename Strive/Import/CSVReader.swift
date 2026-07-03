import Foundation

/// Minimal RFC-4180 CSV reader. Handles quoted fields, embedded commas,
/// embedded newlines, and doubled quote escapes (`""`). Enough for
/// Strava's `activities.csv`; not a general-purpose CSV lib.
enum CSVReader {
    static func parse(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var field = ""
        var row: [String] = []
        var inQuotes = false
        var i = text.startIndex

        while i < text.endIndex {
            let c = text[i]
            if inQuotes {
                if c == "\"" {
                    let next = text.index(after: i)
                    if next < text.endIndex, text[next] == "\"" {
                        field.append("\"")
                        i = text.index(after: next)
                        continue
                    }
                    inQuotes = false
                } else {
                    field.append(c)
                }
            } else {
                switch c {
                case "\"":
                    inQuotes = true
                case ",":
                    row.append(field); field = ""
                case "\r":
                    break // handled by \n
                case "\n":
                    row.append(field); field = ""
                    rows.append(row); row = []
                default:
                    field.append(c)
                }
            }
            i = text.index(after: i)
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }
        return rows
    }
}
