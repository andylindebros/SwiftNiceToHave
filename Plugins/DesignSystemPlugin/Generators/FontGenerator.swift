//
//  TypoGenerator.swift
//
//
//  Created by Andreas Linde on 2023-09-17.
//

import Foundation
import PackagePlugin

enum FontGenerator {
    @discardableResult static func generate(from collection: FontDefinition, outputDir: URL, fileManager: FileManager = FileManager.default) throws -> URL {

        let extensionContent = try createExtension(for: collection.properties, withConfig: collection.config)

        let extensionFile = outputDir.appending(path: "GeneratedFonts.swift")

        fileManager.createFile(atPath: extensionFile.path, contents: extensionContent.data(using: .utf8))

        return outputDir
    }

    static func createExtension(for properties: FontPropertiesCollection, withConfig config: FontConfigCollection) throws -> String {
        """
        /// Note! This is a generated file. Any changes within this file will be overwritten.
        #if canImport(UIKit)
        import UIKit
        #endif
        import SwiftUI
        public protocol DSFont {
            var textStyling: TextStyling { get }
        }

        public struct TextStyling: Sendable {
            public let fontFamily: String
            public let fontSize: CGFloat
            public let fontWeight: String
            public let letterSpacing: CGFloat
            public let lineHeight: CGFloat
            public let paragraphIndent: CGFloat
            public let paragraphSpacing: CGFloat
            public let textCase: String
            public let textDecoration: TextDecoration
        
            public var font: Font {
                Font.custom("\\(fontFamily)-\\(fontWeight)", size: CGFloat(fontSize))
            }
            #if canImport(UIKit)
            public var uiFont: UIFont {
                UIFont(name: "\\(fontFamily)-\\(fontWeight)", size: CGFloat(fontSize))!
            }
            #endif
        }
        
        public extension TextStyling {
            enum TextDecoration: String, Sendable {
                case underline
                case strikeThrough = "line-through"
                case none
            }
        }
        
        public extension Font {
            enum ds {}
        }
        
        public extension Font.ds {
        \(try properties.sorted(by: { $0.0 < $1.0 }).map { name, content in
        """
            enum \(name.camelCased) {
        \(try content.sorted(by: { $0.0 < $1.0 }).map { size, sizeContent in
                """
                        public enum \(size.camelCased): DSFont {
                \(try sizeContent.sorted(by: { $0.0 < $1.0 }).map { fontName, fontcontainer in
                        """
                                    case \(fontName.camelCased)
                        """

                }.joined(separator: "\n"))
                            public var textStyling: TextStyling {
                                switch self {
                                            \(try sizeContent.sorted(by: { $0.0 < $1.0 }).map { fontName, fontcontainer in
                                                        """
                                                            /// Type: \(name.upperCamelCased), Size: \(fontcontainer.value.fontSize.strippedFromUnits), Weight: \(fontName.upperCamelCased)
                                                                            case .\(fontName.camelCased): return TextStyling(
                                                                                    fontFamily: "\(fontcontainer.value.fontFamily)",
                                                                                    fontSize: \(fontcontainer.value.fontSize.strippedFromUnits),
                                                                                    fontWeight: "\(fontcontainer.value.fontWeight)",
                                                                                    letterSpacing: \(fontcontainer.value.letterSpacing.strippedFromUnits),
                                                                                    lineHeight: \(fontcontainer.value.lineHeight.strippedFromUnits),
                                                                                    paragraphIndent: \(fontcontainer.value.paragraphIndent.strippedFromUnits),
                                                                                    paragraphSpacing: \(fontcontainer.value.paragraphSpacing.strippedFromUnits),
                                                                                    textCase: "\(fontcontainer.value.textCase)",
                                                                                    textDecoration: TextStyling.TextDecoration(rawValue: "\(fontcontainer.value.textDecoration)") ?? .none
                                                                                )
                                                            """
                                                        }.joined(separator: "\n"))
                                }
                            }
                
                        }
                """
            }.joined(separator: "\n"))
            }
        """
        }.joined(separator: "\n"))
        }
        """
    }
}

extension FontGenerator {
    struct FontContainer: Decodable {
        let value: FontModel
    }

    struct FontModel: Decodable {
        let fontFamily: String
        let fontWeight: String
        let lineHeight: String
        let fontSize: String
        let letterSpacing: String
        let paragraphSpacing: String
        let paragraphIndent: String
        let textCase: String
        let textDecoration: String
    }
}

private extension Dictionary {
    func nestedValue(by path: String) throws -> String {
        let path = path
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .split(separator: ".")
            .map { String($0) }
        if
            let value = nestedValue(by: path),
            let value = value["value"]
        {
            return value
        }
        throw NSError(domain: "Value not found for \(path.joined(separator: "."))", code: 404)
    }

    func nestedValue(by path: [String]) -> [String: String]? {
        guard let dict = self as? [String: Any] else {
            return nil
        }

        let nestedValue = path.reduce(dict) { current, key in
            if current.keys.contains(key), let newValue = current[key] as? [String: Any] {
                return newValue
            }
            return current
        }
        return nestedValue as? [String: String]
    }
}
