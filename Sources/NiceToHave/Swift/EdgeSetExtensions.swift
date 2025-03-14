import Foundation

import SwiftUI

extension Edge.Set: SECH {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension Axis.Set: SECH {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension TextAlignment: @retroactive Encodable {}
extension TextAlignment: @retroactive Decodable {}

extension TextAlignment: SEC {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .leading:
            try container.encode(CodingKeys.leading.rawValue, forKey: .leading)
        case .center:
            try container.encode(CodingKeys.center.rawValue, forKey: .center)
        case .trailing:
            try container.encode(CodingKeys.trailing.rawValue, forKey: .trailing)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .leading:
            self = .leading
        case .center, .none:
            self = .center
        case .trailing:
            self = .trailing
        }
    }

    enum CodingKeys: String, CodingKey {
        case leading, center, trailing
    }
}

extension HorizontalAlignment: @retroactive Hashable {}
extension HorizontalAlignment: @retroactive Encodable {}
extension HorizontalAlignment: @retroactive Decodable {}

extension HorizontalAlignment: SECH {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: HorizontalAlignment, rhs: HorizontalAlignment) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    /// Unik identifierare för varje `HorizontalAlignment`
    private var identifier: String {
        switch self {
        case .leading: return "leading"
        case .center: return "center"
        case .trailing: return "trailing"
        default: return "custom"
        }
    }

    enum CodingKeys: String, CodingKey {
        case leading, center, trailing
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .leading:
            try container.encode(CodingKeys.leading.rawValue, forKey: .leading)
        case .trailing:
            try container.encode(CodingKeys.trailing.rawValue, forKey: .trailing)
        default:
            try container.encode(CodingKeys.center.rawValue, forKey: .center)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .leading:
            self = .leading
        case .center, .none:
            self = .center
        case .trailing:
            self = .trailing
        }
    }
}

extension VerticalAlignment: @retroactive Hashable {}
extension VerticalAlignment: @retroactive Encodable {}
extension VerticalAlignment: @retroactive Decodable {}

extension VerticalAlignment: SECH {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: VerticalAlignment, rhs: VerticalAlignment) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    /// Unik identifierare för varje `HorizontalAlignment`
    private var identifier: String {
        switch self {
        case .top: return "top"
        case .center: return "center"
        case .bottom: return "bottom"
        default: return "custom"
        }
    }

    enum CodingKeys: String, CodingKey {
        case top, center, bottom
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .top:
            try container.encode(CodingKeys.top.rawValue, forKey: .top)
        case .bottom:
            try container.encode(CodingKeys.bottom.rawValue, forKey: .bottom)
        default:
            try container.encode(CodingKeys.center.rawValue, forKey: .center)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .top:
            self = .top
        case .center, .none:
            self = .center
        case .bottom:
            self = .bottom
        }
    }
}

extension Alignment: @retroactive Hashable {}
extension Alignment: @retroactive Encodable {}
extension Alignment: @retroactive Decodable {}

extension Alignment: SECH {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: Alignment, rhs: Alignment) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    /// Unik identifierare för varje `HorizontalAlignment`
    private var identifier: String {
        switch self {
        case .top: return "top"
        case .center: return "center"
        case .bottom: return "bottom"
        case .leading: return "leading"
        case .trailing: return "trailing"
        case .topLeading: return "topLeading"
        case .bottomLeading: return "bottomLeading"
        case .bottomTrailing: return "bottomTrailing"
        default: return "custom"
        }
    }

    enum CodingKeys: String, CodingKey {
        case top, center, bottom, leading, trailing
        case topLeading, topTrailing
        case bottomLeading, bottomTrailing
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .top:
            try container.encode(CodingKeys.top.rawValue, forKey: .top)
        case .bottom:
            try container.encode(CodingKeys.bottom.rawValue, forKey: .bottom)
        case .leading:
            try container.encode(CodingKeys.leading.rawValue, forKey: .leading)
        case .trailing:
            try container.encode(CodingKeys.trailing.rawValue, forKey: .trailing)
        case .topLeading:
            try container.encode(CodingKeys.topLeading.rawValue, forKey: .topLeading)
        case .topTrailing:
            try container.encode(CodingKeys.topTrailing.rawValue, forKey: .topTrailing)
        case .bottomLeading:
            try container.encode(CodingKeys.bottomLeading.rawValue, forKey: .bottomLeading)
        case .bottomTrailing:
            try container.encode(CodingKeys.bottomTrailing.rawValue, forKey: .bottomTrailing)
        default:
            try container.encode(CodingKeys.center.rawValue, forKey: .center)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .top:
            self = .top
        case .center, .none:
            self = .center
        case .bottom:
            self = .bottom
        case .leading:
            self = .leading
        case .trailing:
            self = .trailing
        case .topLeading:
            self = .topLeading
        case .topTrailing:
            self = .topTrailing
        case .bottomLeading:
            self = .bottomLeading
        case .bottomTrailing:
            self = .bottomTrailing
        }
    }
}

extension ContentMode: @retroactive Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first

        switch key {
        case .fit:
            self = .fit
        case .fill:
            self = .fill
        case .none:
            self = .fill
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .fill:
            try container.encode(CodingKeys.fill.rawValue, forKey: .fill)
        case .fit:
            try container.encode(CodingKeys.fit.rawValue, forKey: .fit)
        }
    }

    enum CodingKeys: String, CodingKey {
        case fit, fill
    }
}
