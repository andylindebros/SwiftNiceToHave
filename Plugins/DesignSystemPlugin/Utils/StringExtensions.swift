import Foundation

extension String {
    private var lowercasingFirst: String { prefix(1).lowercased() + dropFirst() }
    private var uppercasingFirst: String { prefix(1).uppercased() + dropFirst() }

    var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        let first = parts.first!.lowercasingFirst
        let rest = parts.dropFirst().map { $0.uppercasingFirst }

        return ([first] + rest).joined()
    }

    var upperCamelCased: String {
        prefix(1).capitalized + dropFirst().lowercased().camelCased
    }

    func asDoublePercentage() throws -> String {
        guard
            let value = Double(self)
        else {
            throw NSError(domain: "Cannot convert \(self) to Double", code: 400)
        }
        return "\(value / 100)"
    }

    var strippedFromUnits: String {
        if hasSuffix("px") {
            return String(dropLast(2))
        }
        if hasSuffix("%") {
            return String(dropLast(1))
        }
        return self
    }

    var lengthAdjusted: String {
        if count < 3 {
            return "type_" + self
        }
        return self
    }

    var asReference: String {
        self.replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .split(separator: ".")
            .map { String($0).camelCased.lengthAdjusted }
            .joined(separator: ".")
    }
}
