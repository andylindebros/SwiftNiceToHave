import Foundation

public extension NiceToHave {
    actor AsyncStreamer<Value: Sendable>: Sendable {
        public init(initValue: Value, logger: NiceToHave.Logger? = nil, eventLogLevel: NiceToHave.LogLevel = .debug) {
            value = initValue
            self.logger = logger
            self.eventLogLevel = eventLogLevel
        }

        private var subscribers: [UUID: AsyncStream<Value>.Continuation] = [:]
        private var subscriptionWaiters: [UUID: CheckedContinuation<Void, Error>] = [:]

        private let logger: NiceToHave.Logger?
        private let eventLogLevel: NiceToHave.LogLevel

        public private(set) var value: Value { didSet {
            for continuation in subscribers.values {
                continuation.yield(value)
            }
        }}

        public func getValue() async -> Value {
            value
        }

        public var hasSubscribers: Bool {
            !subscribers.isEmpty
        }

        /// Waits until at least one `stream()` subscriber is registered, so tests can send
        /// without racing the internal registration `Task`.
        public func waitUntilSubscribed(timeout: Duration = .seconds(5)) async throws {
            if hasSubscribers {
                return
            }

            try await withCheckedThrowingContinuation { continuation in
                Task {
                    self.addSubscriptionWaiter(continuation, timeout: timeout)
                }
            }
        }

        public nonisolated func stream(returnInitValue: Bool = true) -> AsyncStream<Value> {
            AsyncStream { continuation in
                let id = UUID()

                Task { [weak self] in
                    await self?.registerSubscriber(continuation, id: id)
                    if returnInitValue, let value = await self?.getValue() {
                        continuation.yield(value)
                    }
                }

                continuation.onTermination = { @Sendable _ in
                    Task { [weak self = self] in
                        await self?.removeSubscriber(withId: id)
                    }
                }
            }
        }

        public func cancel() async {
            for continuation in subscribers.values {
                continuation.finish()
            }
        }

        public func send(_ value: Value, file: StaticString = #file, line: UInt = #line, function: StaticString = #function) async {
            eventLogLevel.log(value, with: logger, file: file, line: line, function: function)
            self.value = value
        }

        private func addSubscriptionWaiter(
            _ continuation: CheckedContinuation<Void, Error>,
            timeout: Duration
        ) {
            if hasSubscribers {
                continuation.resume()
                return
            }

            let id = UUID()
            subscriptionWaiters[id] = continuation
            Task {
                try? await Task.sleep(for: timeout)
                self.timeoutSubscriptionWaiter(id: id)
            }
        }

        private func timeoutSubscriptionWaiter(id: UUID) {
            guard let continuation = subscriptionWaiters.removeValue(forKey: id) else {
                return
            }
            continuation.resume(throwing: AsyncStreamerWaitError.timeout)
        }

        private func registerSubscriber(_ continuation: AsyncStream<Value>.Continuation, id: UUID) async {
            if let current = subscribers[id] {
                current.finish()
            }
            subscribers[id] = continuation
            let waiters = subscriptionWaiters
            subscriptionWaiters.removeAll()
            for waiter in waiters.values {
                waiter.resume()
            }
        }

        private func removeSubscriber(withId subscriberId: UUID) async {
            subscribers.removeValue(forKey: subscriberId)
        }
    }

    enum AsyncStreamerWaitError: Error {
        case timeout
    }
}
