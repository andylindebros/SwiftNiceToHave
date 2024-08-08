import Foundation

public protocol TaskManagerProvider {
    func singleTask(_ task: Task<Void, Never>, withID id: String)
    func cancelTask(withID id: String)
}

public class TaskManager: TaskManagerProvider {
    init() {}
    private var tasks = [String: Task<Void, Never>]()

    public func singleTask(_ task: Task<Void, Never>, withID id: String) {
        tasks[id]?.cancel()
        tasks[id] = task
    }

    public func cancelTask(withID id: String) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
    }
}

public extension TaskManager {
    struct Mock: TaskManagerProvider {
        public init() {}
        public func singleTask(_: Task<Void, Never>, withID _: String) {}
        public func cancelTask(withID _: String) {}
    }
}
