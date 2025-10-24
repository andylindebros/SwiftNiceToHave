import Foundation
import PackagePlugin
import SwiftUI

enum ShadowGenerator {
    @discardableResult static func generate(by collection: SchemaShadow, outputDir: URL, fileManager: FileManager = FileManager.default) throws -> URL {

        let extensionContent = try createExtension(for: collection)

        let extensionFile = outputDir.appending(path: "GeneratedShadows.swift")

        fileManager.createFile(atPath: extensionFile.path, contents: extensionContent.data(using: .utf8))

        return extensionFile
    }

    static func createExtension(for models: SchemaShadow) throws -> String {
        """
        /// Note! This is a generated file. Any changes within this file will be overwritten.
        #if canImport(UIKit)
        import UIKit
        #endif
        import SwiftUI

        public extension DS {
            struct ShadowModel {
                public let xValue: Double
                public let yValue: Double
                public let spread: Double
                public let red: Double
                public let green: Double
                public let blue: Double
                public let alpha: Double
            }
            enum ShadowType {
        \(models.sorted(by: { $0.0 < $1.0 }).map { key, value in
                """
                        case \(key.camelCased)
                """
                }.joined(separator: "\n"))
                
                func model(for scheme: ColorScheme) -> ShadowModel {
                    switch self {
        \(try models.sorted(by: { $0.0 < $1.0 }).map { key, theme in
                    """
                                case .\(key.camelCased):
                                    switch scheme {
                                    case .dark:
                                        return ShadowModel(xValue: \(theme.dark.value.xValue.strippedFromUnits), yValue: \(theme.dark.value.yValue.strippedFromUnits), spread: \(theme.dark.value.blur.strippedFromUnits), red: \(try theme.dark.value.nativeColor().red), green: \(try theme.dark.value.nativeColor().green), blue: \(try theme.dark.value.nativeColor().blue), alpha: \(try theme.dark.value.nativeColor().alpha))

                                    default:
                                        return ShadowModel(xValue: \(theme.light.value.xValue.strippedFromUnits), yValue: \(theme.light.value.yValue.strippedFromUnits), spread: \(theme.light.value.blur.strippedFromUnits), red: \(try theme.light.value.nativeColor().red), green: \(try theme.light.value.nativeColor().green), blue: \(try theme.light.value.nativeColor().blue), alpha: \(try theme.light.value.nativeColor().alpha))
                                    }

                    """}.joined(separator: "\n"))
                    }
                }
                #if canImport(UIKit)
                func model(for style: UIUserInterfaceStyle) -> ShadowModel {
                    switch self {
        \(try models.sorted(by: { $0.0 < $1.0 }).map { key, theme in
                    """
                                case .\(key.camelCased):
                                    switch style {
                                        case .dark:
                                            return ShadowModel(xValue: \(theme.dark.value.xValue.strippedFromUnits), yValue: \(theme.dark.value.yValue.strippedFromUnits), spread: \(theme.dark.value.blur.strippedFromUnits), red: \(try theme.dark.value.nativeColor().red), green: \(try theme.dark.value.nativeColor().green), blue: \(try theme.dark.value.nativeColor().blue), alpha: \(try theme.dark.value.nativeColor().alpha))

                                        default:
                                            return ShadowModel(xValue: \(theme.light.value.xValue.strippedFromUnits), yValue: \(theme.light.value.yValue.strippedFromUnits), spread: \(theme.light.value.blur.strippedFromUnits), red: \(try theme.light.value.nativeColor().red), green: \(try theme.light.value.nativeColor().green), blue: \(try theme.light.value.nativeColor().blue), alpha: \(try theme.light.value.nativeColor().alpha))
                                        }

                    """}.joined(separator: "\n"))
                    }
                }
                #endif
            }
        }
        """
    }
}

extension ShadowGenerator {
    struct Theme: Decodable {
        let light: SchemeModel
        let dark: SchemeModel
    }

    struct SchemeModel: Decodable {
        let value: ShadowModel
    }

    struct ColorModel {
        let red: String
        let green: String
        let blue: String
        let alpha: String
    }

    struct ShadowModel: Decodable {
        let xValue: String
        let yValue: String
        let blur: String
        let spread: String
        let color: String
        let type: String
        func nativeColor() throws -> ColorModel {
            if color.prefix(4) == "rgba" {
                let colorArr = color
                    .replacingOccurrences(of: "rgba(", with: "")
                    .replacingOccurrences(of: ")", with: "")
                    .replacingOccurrences(of: " ", with: "")
                    .split(separator: ",")
                    .compactMap { String($0) }
                return ColorModel(red: colorArr[0], green: colorArr[1], blue: colorArr[2], alpha: colorArr[3])
            }
            throw NSError(domain: "The provided source of the color of the shadow is invalid", code: 400)
        }

        enum CodingKeys: String, CodingKey {
            case xValue = "x"
            case yValue = "y"
            case blur, spread, color, type
        }
    }
}
