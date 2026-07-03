import Foundation

/// Placeholder for the ZIP extraction step. iOS 17's `Archive` API doesn't
/// cover ZIP directly, so the next commit either pulls in ZIPFoundation via
/// SwiftPM or delegates to `Compression.framework` + a small ZIP reader.
///
/// For now the import flow accepts an already-extracted directory (which
/// the user can produce with the Files app's "Uncompress" action) so the
/// end-to-end path is functional without the dependency.
enum ArchiveExtractor {
    static func locateActivitiesCSV(in directory: URL) -> URL? {
        let fm = FileManager.default
        guard let e = fm.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return nil
        }
        for case let url as URL in e where url.lastPathComponent == "activities.csv" {
            return url
        }
        return nil
    }
}
