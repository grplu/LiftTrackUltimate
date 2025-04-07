import SwiftUI

public extension Color {
    // Initialize from hex string
    init(_ hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Helper static colors with opacity
    static func blueWithOpacity(_ opacity: Double) -> Color {
        return Color(red: 0, green: 0.478, blue: 1, opacity: opacity)
    }
    
    // Alternative way to create transparent colors
    static var blueOpacity20: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.2)
    }
    
    static var blueOpacity30: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.3)
    }
    
    static var blueOpacity40: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.4)
    }
    
    static var blueOpacity50: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.5)
    }
    
    static var blueOpacity80: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.8)
    }
} 