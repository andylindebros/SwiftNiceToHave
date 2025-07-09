import Foundation

public extension AsyncSequence where Element: Sendable, Self: Sendable {
    /// Waits for predicate to be true or throws `WaitError.timedOut` if it takes too long
    @discardableResult func waitUntil(
        timeout: Duration = .seconds(20),
        file: StaticString = #file,
        line: UInt = #line,
        where predicate: @escaping @Sendable (Element) -> Bool
    ) async throws -> Element {
        try await withThrowingTaskGroup(of: Element.self) { continuation in
            continuation.addTask {
                for try await element in self {
                    if predicate(element) {
                        return element
                    }
                }
                // Throw endOfStream if the stream for some reason ends.
                throw WaitError.endOfStream(file, line)
            }

            continuation.addTask {
                try await Task.sleep(for: timeout)
                throw WaitError.timeout(file, line)
            }

            // Return the first task that is completed
            guard let result = try await continuation.next() else {
                throw WaitError.endOfStream(file, line)
            }
            continuation.cancelAll() // Cancel the second task
            return result
        }
    }
}

public enum WaitError: Error, CustomDebugStringConvertible {
    case timeout(StaticString, UInt)
    case endOfStream(StaticString, UInt)

    public var debugDescription: String {
        switch self {
        case let .timeout(file, line):
            return "Timeout error executed from \(file):\(line)"
        case let .endOfStream(file, line):
            return "EndOfStream error executed from \(file):\(line)"
        }
    }
}
