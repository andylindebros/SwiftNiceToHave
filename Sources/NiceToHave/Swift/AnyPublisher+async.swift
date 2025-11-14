import Foundation
import Combine

public enum AsyncError: Error {
    case finishedWithoutValue
}

public extension AnyPublisher {
    func async() async throws -> Output {
        let result: Delivery<Output> = try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = first()
                .sink { result in
                    switch result {
                    case .finished:
                        if finishedWithoutValue {
                            continuation.resume(throwing: AsyncError.finishedWithoutValue)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    finishedWithoutValue = false
                    let value = Delivery(value: value)
                    continuation.resume(with: .success(value))
                }
        }

        return result.value
    }
}

public extension Publisher {
    func async() async throws -> Output {
        return try await eraseToAnyPublisher().async()
    }
}

struct Delivery<Value>: @unchecked Sendable {
    let value: Value
}

struct Promise<T>: @unchecked Sendable {
    let promise: (Result<T, Never>) -> Void
}

nonisolated public func asyncToAnyPublisher<T: Sendable>(_ asyncFunction: @escaping @Sendable () async -> T) -> AnyPublisher<T, Never> {
    Deferred {
        Future { promise in
            let prom = Promise(promise: promise)
            let asyncFunction = asyncFunction
            Task {
                let result = await asyncFunction()
                prom.promise(.success(result))
            }
        }
    }
    .eraseToAnyPublisher()
}
