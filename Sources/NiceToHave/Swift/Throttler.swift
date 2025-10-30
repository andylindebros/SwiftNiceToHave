

import Foundation
import os

/// A generic throttler that emits elements at a fixed interval as an AsyncSequence.
public final actor Throttler<Element: Sendable>: AsyncSequence {
    public typealias AsyncIterator = Iterator
    public typealias Element = Element

    // Immutable properties that can safely be read outside actor isolation
    private let interval: Duration
    private let stream: AsyncStream<Element>

    private let continuation: AsyncStream<Element>.Continuation
    private var queueSize = 0
    private let maxSize: Int
    private let logger = Logger(prefix: "Throttler")

    public init(interval: Duration, maxSize: Int = 100) {
        self.interval = interval
        self.maxSize = maxSize

        var cont: AsyncStream<Element>.Continuation!
        self.stream = AsyncStream<Element> { continuation in
            cont = continuation
        }
        self.continuation = cont
    }

    /// Nonisolated conformance to AsyncSequence
    public nonisolated func makeAsyncIterator() -> Iterator {
        Iterator(
            stream: stream,
            interval: interval,
            onComplete: { [weak self] in
                await self?.decrementQueue()
            }
        )
    }

    public func add(_ element: Element) {
        guard queueSize < maxSize else {
            logger.debug("🍀 Max capacity reached, cannot add more elements.")
            return
        }
        queueSize += 1
        continuation.yield(element)
    }

    private func decrementQueue() {
        if queueSize > 0 {
            queueSize -= 1
        }
    }

    public struct Iterator: AsyncIteratorProtocol {
        public typealias Element = Throttler.Element

        private var streamIterator: AsyncStream<Element>.AsyncIterator
        private let interval: Duration
        private let onComplete: @Sendable () async -> Void

        public init(
            stream: AsyncStream<Element>,
            interval: Duration,
            onComplete: @escaping @Sendable () async -> Void
        ) {
            self.streamIterator = stream.makeAsyncIterator()
            self.interval = interval
            self.onComplete = onComplete
        }

        public mutating func next() async -> Element? {
            guard let element = await streamIterator.next() else { return nil }
            try? await Task.sleep(for: interval)
            await onComplete()
            return element
        }
    }
}
