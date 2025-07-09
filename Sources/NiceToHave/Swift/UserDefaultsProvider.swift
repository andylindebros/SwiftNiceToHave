import Foundation

public protocol UserDefaultsProvider {
    func string(forKey: String) -> String?
    func set(_ value: Any?, forKey defaultName: String)
    func setObject<O: Encodable>(_ value: O, forKey defaultName: String) throws
    func getObject<O: Decodable>(forKey defaultName: String) throws -> O
    func removeObject(forKey: String)
    func value(forKey key: String) -> Any?
}

extension UserDefaults: UserDefaultsProvider, @unchecked @retroactive Sendable {
    public func setObject<O: Encodable>(_ value: O, forKey defaultName: String) throws {
        let data = try JSONEncoder().encode(value)
        set(String(data: data, encoding: .utf8), forKey: defaultName)
    }

    public func getObject<O: Decodable>(forKey key: String) throws -> O {
        guard let json = value(forKey: key) as? String else {
            throw NSError(domain: "Key not found", code: 404)
        }
        return try JSONDecoder().decode(O.self, from: Data(json.utf8))
    }
}

public class UserDefaultsMock: UserDefaultsProvider {
    public init() {}

    private var stringForKeyResponse: String? = nil
    @discardableResult func setStringForKeyResponse(to value: String?) -> Self {
        stringForKeyResponse = value
        return self
    }

    public func setObject<O: Encodable>(_: O, forKey _: String) throws {}

    public func getObject<O: Decodable>(forKey key: String) throws -> O {
        throw NSError(domain: "Key not found", code: 404)
    }

    public func string(forKey _: String) -> String? {
        stringForKeyResponse
    }

    public func set(_: Any?, forKey _: String) {}

    public func removeObject(forKey _: String) {}

    public func value(forKey _: String) -> Any? {
        nil
    }
}
