import SwiftUI
import Foundation

public enum ColorPalletes {
    case darkRoastCoffee
    case skyfall
    
    public var colors: [Color] {
        switch self {
        case .darkRoastCoffee:
            return [
                Color(hex: "3B2D25"),
                Color(hex: "4C3A31"),
                Color(hex: "5E473D"),
                Color(hex: "705449")
            ]
        case .skyfall:
            return [
                Color(hex: "A9BCF5"),
                Color(hex: "89A5E1"),
                Color(hex: "6D86CA"),
                Color(hex: "5167B3"),
                Color(hex: "34499B")
            ]
        }
    }
}

// Extension to create Color from hex string
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
