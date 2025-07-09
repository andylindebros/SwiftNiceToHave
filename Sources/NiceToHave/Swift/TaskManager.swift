import Foundation

public protocol TaskManagerProvider {
    func singleTask(_ task: Task<Void, Never>, withID id: String) async
    func cancelTask(withID id: String) async
}

public actor TaskManager: TaskManagerProvider {
    public init() {}
    private var tasks = [String: Task<Void, Never>]()

    public func singleTask(_ task: Task<Void, Never>, withID id: String) async {
        tasks[id]?.cancel()
        tasks[id] = task
    }

    public func cancelTask(withID id: String) async {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
    }
}

public extension TaskManager {
    struct Mock: TaskManagerProvider {
        public init() {}
        public func singleTask(_: Task<Void, Never>, withID _: String) async {}
        public func cancelTask(withID _: String) async {}
    }
}
