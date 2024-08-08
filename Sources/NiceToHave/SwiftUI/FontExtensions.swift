import CoreGraphics
import CoreText
import SwiftUI
import UIKit

public extension View {
    func font(_ font: Font, color: Color) -> some View {
        self.font(font).foregroundStyle(color)
    }
}

public extension Text {
    func font(_ font: Font, color: Color) -> some View {
        self.font(font).foregroundStyle(color)
    }
}

private enum FontError: Error {
    case failedToRegisterFont
    case failedToFindAsset
    case providerError
    case fontError
    case registerError
}

public extension Font.Weight {
    static func weight(from int: Int) -> Font.Weight? {
        switch int {
        case 100:
            .ultraLight
        case 200:
            .thin
        case 300:
            .light
        case 400:
            .regular
        case 500:
            .medium
        case 600:
            .semibold
        case 700:
            .bold
        case 800:
            .heavy
        case 900:
            .black
        default:
            nil
        }
    }
}

/**
 RegisterFontModifier is used to load fonts for Previews and not intended to be used in production
 */
public struct RegisterFontModifier: ViewModifier {
    init(regular: String, bold: String, in bundle: Bundle) {
        do {
            try registerFont(named: regular, in: bundle)
            try registerFont(named: bold, in: bundle)
        } catch {
            print("❌ Failed to register font with error", error)
        }
    }

    public func body(content: Content) -> some View {
        content
    }

    func registerFont(named name: String, in bundle: Bundle) throws {
        guard let asset = NSDataAsset(name: "\(name)", bundle: bundle)

        else {
            throw FontError.failedToFindAsset
        }

        guard let provider = CGDataProvider(data: asset.data as NSData)

        else {
            throw FontError.providerError
        }

        guard let font = CGFont(provider)
        else {
            throw FontError.fontError
        }

        guard CTFontManagerRegisterGraphicsFont(font, nil)
        else {
            throw FontError.registerError
        }

        print("🍀 Font register succes")
    }
}

public extension View {
    func registerFont(regularName: String, boldName: String, in bundle: Bundle) -> some View {
        modifier(RegisterFontModifier(regular: regularName, bold: boldName, in: bundle))
    }
}
