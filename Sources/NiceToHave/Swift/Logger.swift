import OSLog

public struct Logger {
    private let logger: os.Logger
    private let prefix: String
    init(prefix: String, subsystem: String = #file, category: String = #file) {
        logger = os.Logger(subsystem: subsystem, category: prefix)
        self.prefix = prefix
    }

    func debug(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.debug("\(createMessage(from: values, icon: .debug, file: file, line: line))")
    }

    func info(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.info("\(createMessage(from: values, icon: .info, file: file, line: line))")
    }

    func warning(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.warning("\(createMessage(from: values, icon: .warning, file: file, line: line))")
    }

    func error(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.error("\(createMessage(from: values, icon: .error, file: file, line: line))")
    }

    private func createMessage(from values: [Any?], icon: Icon, file: StaticString = #file, line: UInt = #line) -> String {
        let values = values.map { value in
            guard let value else { return "nil" }
            return "\(value)"
        }
        let fileName = "\(file)".split(separator: "/").last ?? "unknown"
        return "\(fileName) [\(line)]: \(prefix) \(icon.rawValue) \(values.joined(separator: " "))"
    }

    enum Icon: String {
        case debug = "🔷"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
    }
}
