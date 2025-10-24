import Foundation
import PackagePlugin

enum BorderRadiusGenerator {
    @discardableResult static func generate(by collection: SchemaBorderRadius, outputDir: URL, fileManager: FileManager = FileManager.default) throws -> URL {
        let extensionContent = try createExtension(for: collection)

        let extensionFile = outputDir.appending(path: "GeneratedBorderRadius.swift")

        fileManager.createFile(atPath: extensionFile.path, contents: extensionContent.data(using: .utf8))

        return extensionFile
    }

    static func createExtension(for models: SchemaBorderRadius) throws -> String {
        """
        /// Note! This is a generated file. Any changes within this file will be overwritten.
        import SwiftUI
        
        public extension Double.ds {
            enum borderRadius {
        \(models.sorted(by: { $0.0 < $1.0 }).map { key, value in
            """
                    /// Value: \(value.value.strippedFromUnits)
                    public static let \(key.camelCased): Double = \(value.value.strippedFromUnits)
            """
        }.joined(separator: "\n"))
            }
        }
        """
    }
}


    
