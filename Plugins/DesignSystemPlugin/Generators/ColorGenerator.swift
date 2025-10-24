import Foundation
import PackagePlugin

struct DocumentModel: Decodable {
    var schemes: [String: [String: String]]
}

enum ColorExtensionGenerator {
    @discardableResult static func generate(
        from colors: SchemaColors,
        outputDir: URL,
        destinationType: DestinationType,
        fileManager: FileManager = FileManager.default
    ) throws -> URL {

        guard
            let light = colors["light"],
            let dark = colors["dark"]
        else {
            throw NSError(domain: "Cannot find desired color themes", code: 500)
        }

        let colorCollection = light.reduce([String: ColorSet.ColorTheme]()) { stack, newValue in
            var stack = stack
            let dark = dark[newValue.key]
            stack[newValue.key] = .init(
                light: .init(value: newValue.value),
                dark: .init(value: dark ?? newValue.value)
            )
            return stack
        }

        let extensionContent = try createExtension(for: colorCollection, destinationType: destinationType)

        let extensionFile = outputDir.appending(path: "GeneratedColors.swift")


        let result = fileManager.createFile(atPath: extensionFile.path, contents: extensionContent.data(using: .utf8))

        return extensionFile
    }

    // static let opacityNames: [String] = ["", "medium", "thin"]
    static let opacityNames: [String] = ["", "medium", "thin"]
    static func createExtension(for json: [String: ColorSet.ColorTheme], destinationType: DestinationType) throws -> String {
        """
        /// Note! This is a generated file. Any changes within this file will be overwritten.
        #if canImport(UIKit)
            import UIKit
        #endif
        import SwiftUI

        public extension Color {
            enum ds {
        \(json.keys.sorted(by: { $0 < $1 }).map { key in
            """
            \(Self.opacityNames.sorted(by: { $0 < $1 }).map { opacity in
                """
                        /// \(key.camelCased)\(opacity.upperCamelCased) Light: #\(json[key]?.light.value ?? ""), Dark: \(json[key]?.light.value ?? "")
                        public static let \(key.camelCased)\(opacity.upperCamelCased) = Color("\([ColorSet.prefix, key.camelCased, opacity != "" ? opacity : nil].compactMap { $0 }.joined(separator: "_").lowercased())", bundle: .\(destinationType.rawValue))
                """
            }.joined(separator: "\n"))
            """
        }.joined(separator: "\n"))
            }
        }
        #if canImport(UIKit)
        public extension UIColor {
            enum ds {
        \(json.keys.sorted(by: { $0 < $1 }).map { key in
            """
            \(Self.opacityNames.sorted(by: { $0 < $1 }).map { opacity in
                """
                        /// \(key.camelCased)\(opacity.upperCamelCased) Light: #\(json[key]?.light.value ?? ""), Dark: \(json[key]?.light.value ?? "")
                        public static let \(key.camelCased)\(opacity.upperCamelCased) = UIColor(named: "\([ColorSet.prefix, key.camelCased, opacity != "" ? opacity : nil].compactMap { $0 }.joined(separator: "_").lowercased())", in: .\(destinationType.rawValue), compatibleWith: .current)!
                """
            }.joined(separator: "\n"))
            """
        }.joined(separator: "\n"))
            }
        }
        #endif
        """
    }
}
