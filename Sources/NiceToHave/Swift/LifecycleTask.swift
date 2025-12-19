#if os(iOS)
    import Foundation
    import UIKit

    public struct LifecycleTask: Sendable, Hashable {
        let task: Task<Void, Error>

        public init(
            priority: TaskPriority? = nil,
            operation: @escaping @Sendable () async -> Void
        ) {
            var activeTask: Task<Void, Error>?
            let lifeCycleStreamer = LifeCycleStreamer()
            task = Task {
                for await isInForeground in lifeCycleStreamer.appLifecycleStream() {
                    if isInForeground {
                        activeTask?.cancel()
                        activeTask = Task(priority: priority) {
                            await operation()
                        }
                    } else {
                        activeTask?.cancel()
                        activeTask = nil
                    }
                }
                if Task.isCancelled {
                    return
                }
                fatalError("Stream ended unexpectedly")
            }
        }

        public func cancel() {
            task.cancel()
        }

        public var isCancelled: Bool {
            task.isCancelled
        }

        private struct LifeCycleStreamer {
            func appLifecycleStream() -> AsyncStream<Bool> {
                AsyncStream { continuation in
                    // Initial state
                    let enterForegroundTask = Task {
                        continuation.yield(await UIApplication.shared.applicationState == .active)
                        for await _ in NotificationCenter.default
                            .publisher(for: UIApplication.didBecomeActiveNotification)
                            .values
                        {
                            continuation.yield(true)
                        }
                        if Task.isCancelled {
                            return
                        }
                        fatalError("Stream ended unexpectedly")
                    }

                    let enterBackgroundTask = Task {
                        for await _ in NotificationCenter.default
                            .publisher(for: UIApplication.didEnterBackgroundNotification)
                            .values
                        {
                            continuation.yield(false)
                        }
                        if Task.isCancelled {
                            return
                        }
                        fatalError("Stream ended unexpectedly")
                    }
                    continuation.onTermination = { _ in
                        enterForegroundTask.cancel()
                        enterBackgroundTask.cancel()
                    }
                }
            }
        }
    }
#endif
