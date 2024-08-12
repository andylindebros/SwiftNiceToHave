//
import Foundation

public extension String {
    var firstCapitalized: String {
        prefix(1).capitalized + dropFirst()
    }

    var asSnakeCased: String? {
        let pattern = "([a-z0-9])([A-Z])"

        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }

    var asCamelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        let first = parts.first!.prefix(1).lowercased() + dropFirst()
        let rest = parts.dropFirst().map { $0.prefix(1).uppercased() + dropFirst() }

        return ([first] + rest).joined()
    }

    var asUpperCamelCased: String {
        prefix(1).capitalized + dropFirst().lowercased().asCamelCased
    }
}

public extension StringProtocol {
    func html2String() async -> String {
        await Data(utf8).html2String()
    }
}

public extension String {
    var asURL: URL? {
        URL(string: self)
    }

    var asInt: Int? {
        Int(self)
    }

    var asDouble: Double? {
        Double(self)
    }

    var asSet: Set<String> {
        [self]
    }

    var asBool: Bool {
        if self == "true" {
            return true
        }
        return false
    }
}
