import Foundation
import PackagePlugin

enum OpacityGenerator {
    @discardableResult static func generate(by collection: SchemaOpacity, outputDir: URL, fileManager: FileManager = FileManager.default) throws -> URL {
        let extensionContent = try createExtension(for: collection)

        let extensionFile = outputDir.appending(path: "GeneratedOpacity.swift")

        fileManager.createFile(atPath: extensionFile.path, contents: extensionContent.data(using: .utf8))

        return extensionFile
    }

    static func createExtension(for models: SchemaOpacity) throws -> String {
        """
        /// Note! This is a generated file. Any changes within this file will be overwritten.
        #if canImport(UIKit)
        import UIKit
        #endif
        import SwiftUI
        
        public extension Double {
            enum ds {}
        }
        public extension Double.ds {
            enum opacity {
        \(models.sorted(by: { $0.0 < $1.0 }).map { key, value in
                """
                        /// Light: \(models[key]?.light.value ?? ""), Dark: \(models[key]?.dark.value ?? "")
                        case \(key.camelCased)
                """
                }.joined(separator: "\n"))
            }
        }
        
        public extension Double.ds.opacity {
        \(try models.sorted(by: { $0.0 < $1.0 }).map { key, value in
            """
                enum \(key.upperCamelCased) {
                    public static let light: Double = \( try value.light.value.strippedFromUnits.asDoublePercentage())
                    public static let dark: Double = \( try value.dark.value.strippedFromUnits.asDoublePercentage())
                }
            """
        }.joined(separator: "\n"))
        }
        
        public extension Double.ds.opacity {
            func value(for scheme: ColorScheme) -> Double {
                switch self {
        \(try models.sorted(by: { $0.0 < $1.0 }).map { key, value in
                    """
                            case .\(key.camelCased):
                                switch scheme {
                                case .dark:
                                    return \( try value.dark.value.strippedFromUnits.asDoublePercentage())
                                default:
                                    return \( try value.light.value.strippedFromUnits.asDoublePercentage())
                                }
                    """
                    }.joined(separator: "\n"))
                }
            }
        
            #if canImport(UIKit)
            func value(for style: UIUserInterfaceStyle) -> Double {
                switch self {
            \(try models.sorted(by: { $0.0 < $1.0 }).map { key, value in
                    """
                            case .\(key.camelCased):
                                switch style {
                                case .dark:
                                    return \( try value.dark.value.strippedFromUnits.asDoublePercentage())
                                default:
                                    return \( try value.light.value.strippedFromUnits.asDoublePercentage())
                                }
                    """
                    }.joined(separator: "\n"))
                }
            }
            #endif
        }
        """
    }
}

extension OpacityGenerator {
    struct OpacityTheme: Decodable {
        let light: OpacityModel
        let dark: OpacityModel
    }

    struct OpacityModel: Decodable {
        let value: String
    }
}
