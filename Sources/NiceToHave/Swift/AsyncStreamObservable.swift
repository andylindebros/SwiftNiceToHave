import SwiftUI

package extension NiceToHave {
    @MainActor @Observable final class AsyncStreamObservable<Element: Sendable> {
        public private(set) var value: Element

        private var task: Task<Void, Never>?
        private let stream: AsyncStream<Element>
        public init(initValue: Element, stream: AsyncStream<Element>) {
            value = initValue
            self.stream = stream
        }

        public func onAppear() {
            task?.cancel()
            // Do not `await self?.stream()` before the `for await` — that would
            // strongly retain this observable for the lifetime of the stream.
            task = Task { [weak self] in
                guard let stream = self?.stream else { return }
                for await value in stream {
                    guard let self else { return }
                    self.value = value
                }
            }
        }

        public func onDisappear() {
            task?.cancel()
            task = nil
        }
    }
}
