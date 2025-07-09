import Network

// MARK: Protocol

public protocol ReachabilityAsyncStream: Sendable {
    func stream() async -> AsyncStream<ReachabilityAsyncStreamImpl.NWPath>
}

// MARK: Implementation

public struct ReachabilityAsyncStreamImpl: ReachabilityAsyncStream {
    public func stream() async -> AsyncStream<ReachabilityAsyncStreamImpl.NWPath> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            let queue = DispatchQueue(label: "NetworkStatusMonitor")

            continuation.yield(monitor.currentPath.asReachabilityNWPath)

            monitor.pathUpdateHandler = { path in
                continuation.yield(path.asReachabilityNWPath)
            }

            monitor.start(queue: queue)

            continuation.onTermination = { @Sendable _ in
                monitor.cancel()
            }
        }
    }

    public struct NWPath: Equatable, Sendable {
        public init(isExpensive: Bool, status: Status) {
            self.isExpensive = isExpensive
            self.status = status
        }

        let isExpensive: Bool
        let status: Status
    }

    public enum Status: Equatable, Sendable {
        init(status: Network.NWPath.Status) {
            self = switch status {
            case .satisfied:
                .satisfied
            case .unsatisfied:
                .unsatisfied
            case .requiresConnection:
                .requiresConnection
            @unknown default:
                .unsatisfied
            }
        }

        case satisfied
        case unsatisfied
        case requiresConnection
    }
}

// MARK: Dependency extensions

private extension Network.NWPath {
    var asReachabilityNWPath: ReachabilityAsyncStreamImpl.NWPath {
        .init(
            isExpensive: isExpensive,
            status: ReachabilityAsyncStreamImpl.Status(status: status)
        )
    }
}

// MARK: Mock

public struct ReachabilityAsyncStreamMock: ReachabilityAsyncStream {
    init(currentPath: ReachabilityAsyncStreamImpl.NWPath) {
        let (stream, continuation) = AsyncStream<ReachabilityAsyncStreamImpl.NWPath>.makeStream()
        internalStream = stream
        self.continuation = continuation
        self.currentPath = currentPath
    }

    private let internalStream: AsyncStream<ReachabilityAsyncStreamImpl.NWPath>
    private let continuation: AsyncStream<ReachabilityAsyncStreamImpl.NWPath>.Continuation
    private let currentPath: ReachabilityAsyncStreamImpl.NWPath

    public func stream() -> AsyncStream<ReachabilityAsyncStreamImpl.NWPath> {
        internalStream
    }

    func send(path: ReachabilityAsyncStreamImpl.NWPath) {
        continuation.yield(path)
    }

    func finish() {
        continuation.finish()
    }
}
