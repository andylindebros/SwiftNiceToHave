import Foundation
import Observation

@available(iOS 17.0, *)
@MainActor
public extension Observable where Self: AnyObject {
    @discardableResult
    func waitUntil<Value>(
        _ keyPath: @MainActor @autoclosure () -> KeyPath<Self, Value>,
        timeout: TimeInterval = 5,
        satisfies condition: @escaping (Value) -> Bool
    ) async throws -> Value {
        if condition(self[keyPath: keyPath()]) { return self[keyPath: keyPath()] }

        let start = Date()

        while !condition(self[keyPath: keyPath()]) {
            if Date().timeIntervalSince(start) >= timeout {
                throw ObservableError.timeout
            }

            await Task.yield()
        }

        return self[keyPath: keyPath()]
    }
}

enum ObservableError: Error {
    case timeout
}
