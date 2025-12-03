@preconcurrency import Combine

public extension AnyPublisher where Failure == Never, Output: Sendable {
    func asyncStream() -> AsyncStream<Output> {
        AsyncStream { continuation in
            let cancellable = self.sink { value in
                continuation.yield(value)
            }
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
