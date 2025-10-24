import Foundation
import PackagePlugin

enum CommonGenerator {
    @discardableResult static func generate(outputDir: URL, fileManager: FileManager = FileManager.default) throws -> URL {
        let extensionContent = try createExtension()

        let extensionFile = outputDir.appending(path: "GeneratedCommon.swift")

        fileManager.createFile(atPath: extensionFile.path, contents: extensionContent.data(using: .utf8))

        return extensionFile
    }

    static func createExtension() throws -> String {
        """
        /// Note! This is a generated file. Any changes within this file will be overwritten.
        import SwiftUI
        
        public enum DS {}
        """
    }
}



