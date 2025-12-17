import Foundation

public actor Debounce<T: Sendable> {
    public init(timeout: Duration, block: @Sendable @escaping (T) async -> Void) {
        self.timeout = timeout
        self.block = block
    }

    private let block: @Sendable (T) async -> Void
    private let timeout: Duration
    private var task: Task<Void, Never>?
    private var lastValue: T?

    public func lastValue() async -> T? {
        lastValue
    }

    public func emit(_ value: T, force: Bool = false) async {
        lastValue = value
        if force {
            return await block(value)
        }

        task?.cancel()
        task = Task {[timeout, block] in
            do {
                try await Task.sleep(for: timeout)
                guard !Task.isCancelled else { return }
                lastValue = nil
                await block(value)
            } catch {}
        }
    }
}
