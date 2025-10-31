import OSLog

public struct Logger {
    private let logger: os.Logger
    private let prefix: String

    public init(prefix: String = "", subsystem: String = #file) {
        logger = os.Logger(subsystem: subsystem, category: prefix)
        self.prefix = prefix
    }

    public func debug(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.debug("\(createMessage(from: values, icon: .debug, file: file, line: line))")
    }

    public func info(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.info("\(createMessage(from: values, icon: .info, file: file, line: line))")
    }

    public func warning(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.warning("\(createMessage(from: values, icon: .warning, file: file, line: line))")
    }

    public func error(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.error("\(createMessage(from: values, icon: .error, file: file, line: line))")
    }

    private func createMessage(from values: [Any?], icon: Icon, file: StaticString = #file, line: UInt = #line) -> String {
        let values = values.map { value in
            guard let value else { return "nil" }
            return "\(value)"
        }
        let fileName = "\(file)".split(separator: "/").last ?? "unknown"
        return [
            [
                icon.rawValue,
                fileName,
                "[\(line)]:",
                prefix,
            ].compactMap { "\($0)" != "" ? "\($0)" : nil },
            values,
        ].flatMap { $0 }.joined(separator: " ")
    }

    enum Icon: String {
        case debug = "🔷"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
    }
}
