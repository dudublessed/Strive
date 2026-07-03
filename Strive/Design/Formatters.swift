import Foundation

enum Formatters {
    /// e.g. `12.42 km`
    static func distance(_ meters: Double) -> String {
        let km = meters / 1_000
        return String(format: "%.2f km", km)
    }

    /// e.g. `1:24:07` or `24:07`
    static func duration(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    /// e.g. `4:32 /km`
    static func pace(secPerKm: Double) -> String {
        guard secPerKm.isFinite, secPerKm > 0 else { return "—" }
        let m = Int(secPerKm) / 60
        let s = Int(secPerKm) % 60
        return String(format: "%d:%02d /km", m, s)
    }

    /// e.g. `284 m`
    static func elevation(_ meters: Double) -> String {
        String(format: "%.0f m", meters)
    }

    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}
