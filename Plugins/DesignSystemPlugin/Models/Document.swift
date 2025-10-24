typealias SchemaColors = [String: [String: String]]
typealias SchemaOpacity = [String: OpacityTheme]
typealias SchemaSpacing = [String: SpacingModel]
typealias SchemaBorderRadius = [String: BorderRadiusModel]
typealias SchemaShadow = [String: ShadowGenerator.Theme]


struct Schema: Decodable {
    let colors: SchemaColors?
    let opacity: SchemaOpacity?
    let spacing: SchemaSpacing?
    let borderRadius: SchemaBorderRadius?
    let shadow: SchemaShadow?
    let font: FontDefinition?
}

enum DestinationType: String {
    init?(rawValue: String?) {
        switch rawValue {
        case "main": self = .main
        case "module": self = .module
        default: return nil
        }
    }
    case main
    case module
}

struct OpacityTheme: Decodable {
    let light: OpacityModel
    let dark: OpacityModel
}

struct OpacityModel: Decodable {
    let value: String

    var opacityValue: String {
        return (try? value.strippedFromUnits.asDoublePercentage()).flatMap { "\($0)" } ?? "1.000"
    }
}

struct SpacingModel: Decodable {
    let value: String
}

struct BorderRadiusModel: Decodable {
    let value: String
}

struct FontDefinition: Decodable {
    let config: FontConfigCollection
    let properties: FontPropertiesCollection
}

typealias FontConfigCollection = [String: [String: [String: String]]]
typealias FontPropertiesCollection =  [String: [String: [String: FontGenerator.FontContainer]]]
