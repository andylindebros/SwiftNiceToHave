import Foundation
import PackagePlugin

enum ColorSet {
    static let prefix = "ds"

    static func createAssetCatalog(at outputDir: URL, fileManager: FileManager) throws -> URL {
        let catalog = outputDir.appending(path: "GeneratedAssets.xcassets")

        try? fileManager.removeItem(atPath: catalog.path)

        try fileManager.createDirectory(atPath: catalog.path, withIntermediateDirectories: true)
        return catalog
    }

    static func createColorSets(from colors: SchemaColors, opacities: SchemaOpacity, outputDir: URL, fileManager: FileManager = FileManager.default) throws {

        let assetCatalog = try createAssetCatalog(at: outputDir, fileManager: fileManager)

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

        // Add ColorSets to asset catalog
        let colorsPath = assetCatalog.appending(path: "Colors")
        try fileManager.createDirectory(atPath: colorsPath.path, withIntermediateDirectories: true)

        fileManager.createFile(
            atPath: colorsPath.appending(path: "Contents.json").path,
            contents: Self.renderFolderCatalogContentsTemplate().data(using: .utf8)
        )

        for key in colorCollection.keys {
            guard let value = colorCollection[key] else {
                throw NSError(domain: "Color theme was not provided for key \(key)", code: 500)
            }
            try createColorSet(withName: key.camelCased, withTheme: value, opacities: opacities, at: colorsPath)
        }
    }
}

private extension ColorSet {
    static func createColorSet(withName name: String, withTheme theme: ColorTheme, opacities: SchemaOpacity, at parentDirectory: URL, fileManager: FileManager = FileManager.default) throws {
        let opacityNames: [String: String] = ["primary": "", "secondary": "medium", "tertiary": "thin"]
        // let opacityNames: [String: String] = ["primary": ""]

        for (key, value) in opacities {
            let outputFolderPath = parentDirectory.appending(path: "\([Self.prefix, name, opacityNames[key] != "" ? opacityNames[key] : nil].compactMap { $0 }.joined(separator: "_").lowercased()).colorset")
            try? fileManager.removeItem(atPath: outputFolderPath.path)
            try fileManager.createDirectory(atPath: outputFolderPath.path, withIntermediateDirectories: false)
            try fileManager.createFile(
                atPath: outputFolderPath.appending(path: "Contents.json").path,
                contents: colorJson(for: theme, opacity: value).data(using: .utf8)
            )
        }
    }

    static func renderFolderCatalogContentsTemplate() -> String {
        """
        {
          "info" : {
            "author" : "DesignSystem",
            "version" : 1
          }
        }
        """
    }

    static func colorJson(for theme: ColorTheme, opacity: OpacityTheme) throws -> String {
        guard
            let lightValue = theme.light.chunkedValue
        else {
            return ""
        }
        let darkValue = theme.dark.chunkedValue

        let colorJSON = """
            {
              "colors" : [
                {
                  "color" : {
                    "color-space" : "srgb",
                    "components" : {
                      "alpha" : "\(opacity.light.opacityValue)",
                      "red" : "0x\(lightValue[0])",
                      "green" : "0x\(lightValue[1])",
                      "blue" : "0x\(lightValue[2])"
                    }
                  },
                  "idiom" : "universal"
                },
            \(darkValue != nil ? """
                    {
                        "appearances" : [
                            {
                              "appearance" : "luminosity",
                              "value" : "dark"
                            }
                        ],
                          "color" : {
                            "color-space" : "srgb",
                            "components" : {
                              "alpha" : "\(opacity.dark.opacityValue)",
                              "red" : "0x\(darkValue?[0] ?? "")",
                              "green" : "0x\(darkValue?[1] ?? "")",
                              "blue" : "0x\(darkValue?[2] ?? "")"
                            }
                          },
                        "idiom" : "universal"
                    }
                """ : ""
            )
          ],
          "info" : {
            "author" : "DesignSystem",
            "version" : 1
          }
        }
        """

        return colorJSON
    }
}

extension ColorSet {
    struct ColorTheme: Decodable {
        let light: ColorModel
        let dark: ColorModel

        enum CodingKeys: String, CodingKey {
            case light = "Light"
            case dark = "Dark"
        }
    }

    struct ColorModel: Decodable {
        let value: String

        var chunkedValue: [String.SubSequence]? {
            let chunked = value.replacingOccurrences(of: "#", with: "")
                .chunks(ofSize: 2)

            guard
                chunked.count == 3,
                value.starts(with: "#")
            else {
                return nil
            }

            return chunked
        }
    }
}
