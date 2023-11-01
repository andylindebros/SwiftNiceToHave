import SwiftUI
#if os(iOS)
    import UIKit
#elseif os(macOS)
    import AppKit
#endif

public enum ColorType: String, Sendable, Codable {
    case white, black, green, blue, yellow, orange, red, pink, clear, gray

    public var color: Color {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        case .green:
            return .green
        case .blue:
            return .blue
        case .yellow:
            return .yellow
        case .orange:
            return .orange
        case .red:
            return .red
        case .pink:
            return .pink
        case .clear:
            return .clear
        case .gray:
            return .gray
        }
    }
}

internal extension Color {
    #if os(macOS)
        typealias SystemColor = NSColor
    #else
        typealias SystemColor = UIColor
    #endif

    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        #if os(macOS)
            SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        // Note that non RGB color will raise an exception, that I don't now how to catch because it is an Objc exception.
        #else
            guard SystemColor(self).getRed(&r, green: &g, blue: &b, alpha: &a) else {
                // Pay attention that the color should be convertible into RGB format
                // Colors using hue, saturation and brightness won't work
                return nil
            }
        #endif

        return (r, g, b, a)
    }
}

public extension Color {
    var hexCode: String {
        let colorComponents = SystemColor(self).cgColor.components!
        if colorComponents.count < 4 {
            return String(format: "%02x%02x%02x", Int(colorComponents[0] * 255.0), Int(colorComponents[0] * 255.0), Int(colorComponents[0] * 255.0)).uppercased()
        }
        return String(format: "%02x%02x%02x", Int(colorComponents[0] * 255.0), Int(colorComponents[1] * 255.0), Int(colorComponents[2] * 255.0)).uppercased()
    }

    init(hexString: String) {
        let hexint = Self.intFromHexString(hexString)
        let red = CGFloat((hexint & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xFF) >> 0) / 255.0

        self.init(red: red, green: green, blue: blue, opacity: 1)
    }

    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }

    private static func intFromHexString(_ hexStr: String) -> UInt64 {
        var hexInt: UInt64 = 0
        let scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&hexInt)

        return hexInt
    }
}
