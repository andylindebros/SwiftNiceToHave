import Foundation
import PackagePlugin

@main
struct DesignSystemPlugin: CommandPlugin {
    func performCommand(context _: PluginContext, arguments: [String]) async throws {
        // MARK: - Argument parsing

        var schemaPath: String?
        var outputPath: String?
        var destinationType: DestinationType = .module // default

        var it = arguments.makeIterator()
        while let arg = it.next() {
            switch arg {
            case "--schema":
                schemaPath = it.next()
            case "--output":
                outputPath = it.next()
            case "--type":
                destinationType = DestinationType(rawValue: it.next()) ?? DestinationType.module
            default:
                break
            }
        }

        guard let schemaPath else {
            Diagnostics.error("❌ Missing required argument: --schema <path>")
            return
        }

        // Expand ~ to full path
        func expandTilde(in path: String) -> String {
            if path.hasPrefix("~") {
                let home = FileManager.default.homeDirectoryForCurrentUser.path
                return home + path.dropFirst()
            }
            return path
        }

        // MARK: - Resolve URLs

        let schemaURL = URL(fileURLWithPath: expandTilde(in: schemaPath))
        let outputDir: URL

        guard let outputPath else {
            throw Error.invalidOutputPath
        }

        outputDir = URL(fileURLWithPath: expandTilde(in: outputPath), isDirectory: true)

        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        // MARK: - Load and parse schema

        guard FileManager.default.fileExists(atPath: schemaURL.path) else {
            Diagnostics.error("❌ Schema file not found at \(schemaURL.path)")
            return
        }

        let data = try Data(contentsOf: schemaURL)

        let jsonDecoder = JSONDecoder()

        let model = try jsonDecoder.decode(Schema.self, from: data)

        try CommonGenerator.generate(outputDir: outputDir)

        if let colors = model.colors, let opacity = model.opacity {
            try ColorSet.createColorSets(from: colors, opacities: opacity, outputDir: outputDir)

            let colors = try ColorExtensionGenerator.generate(
                from: colors,
                outputDir: outputDir,
                destinationType: destinationType
            )
        }

        if let spacing = model.spacing {
            let spacingFile = try SpacingGenerator.generate(by: spacing, outputDir: outputDir)
        }

        if let opacity = model.opacity {
            try OpacityGenerator.generate(by: opacity, outputDir: outputDir)
        }

        if let borderRadius = model.borderRadius {
            try BorderRadiusGenerator.generate(by: borderRadius, outputDir: outputDir)
        }

        if let collection = model.shadow {
            try ShadowGenerator.generate(by: collection, outputDir: outputDir)
        }

        if let collection = model.font {
            try FontGenerator.generate(from: collection, outputDir: outputDir)
        }

        print("✅ Generated code at \(outputDir.path)")
    }

    // MARK: - Code generator

    func generateSwiftCode(from json: [String: Any]) throws -> String {
        guard let title = json["title"] as? String ?? json["name"] as? String else {
            throw NSError(domain: "CodeGen", code: 1, userInfo: [NSLocalizedDescriptionKey: "Schema must contain 'title' or 'name'."])
        }

        var output = """
        // Generated file — Do not edit manually
        // Generated at \(Date())

        import Foundation

        public struct \(title): Codable {
        """

        if let props = json["properties"] as? [String: [String: Any]] {
            for (key, value) in props {
                let type = mapJSONType(value["type"] as? String)
                output += "\n    public var \(key): \(type)"
            }
        }

        output += "\n}\n"
        return output
    }

    func mapJSONType(_ jsonType: String?) -> String {
        switch jsonType {
        case "string": return "String"
        case "integer": return "Int"
        case "number": return "Double"
        case "boolean": return "Bool"
        default: return "String"
        }
    }
}

extension DesignSystemPlugin {
    enum Error: Swift.Error {
        case invalidOutputPath
    }
}
