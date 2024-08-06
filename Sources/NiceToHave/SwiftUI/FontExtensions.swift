import CoreGraphics
import CoreText
import SwiftUI
import UIKit

private enum FontError: Error {
    case failedToRegisterFont
    case failedToFindAsset
    case providerError
    case fontError
    case registerError
}
