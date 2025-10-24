import Foundation
import PackagePlugin

enum SpacingGenerator {
    @discardableResult static func generate(by collection: SchemaSpacing, outputDir: URL, fileManager: FileManager = FileManager.default) throws -> URL {

        let extensionContent = try createExtension(for: collection)

        let extensionFile = outputDir.appending(path: "GeneratedSpacing.swift")

        fileManager.createFile(atPath: extensionFile.path, contents: extensionContent.data(using: .utf8))

        return extensionFile
    }

    static func createExtension(for models: [String: SpacingModel]) throws -> String {
        """
        /// Note! This is a generated file. Any changes within this file will be overwritten.
        import UIKit
        import SwiftUI

        public extension Double.ds {
            enum spacing {
        \(models.sorted(by: { $0.0 < $1.0 }).map { key, value in
            """
                    /// Value \(value.value.strippedFromUnits)
                    public static let \(key.replacingOccurrences(of: "-", with: "").camelCased): Double = \(value.value.strippedFromUnits)
            """
        }.joined(separator: "\n"))
            }
        }
        """
    }
}

