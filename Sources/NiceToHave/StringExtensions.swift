import Foundation

public extension String {
    var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        let first = parts.first!.prefix(1).lowercased() + dropFirst()
        let rest = parts.dropFirst().map { $0.prefix(1).uppercased() + dropFirst() }

        return ([first] + rest).joined()
    }

    var upperCamelCased: String {
        prefix(1).capitalized + dropFirst().lowercased().camelCased
    }
}
