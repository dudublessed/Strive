import SwiftUI

enum Theme {
    enum Palette {
        static let surface = Color.white
        static let accent = Color(hex: 0x534AB7)
        static let accentFill = Color(hex: 0xEEEDFE)
        static let accentText = Color(hex: 0x26215C)
        static let subtleText = Color(hex: 0x6B7280)
        static let divider = Color(hex: 0xE5E7EB)
    }

    enum Radius {
        static let card: CGFloat = 16
        static let control: CGFloat = 12
        static let pill: CGFloat = 999
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24
    }
}

private extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
