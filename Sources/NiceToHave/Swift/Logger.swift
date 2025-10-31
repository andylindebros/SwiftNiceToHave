/// A simple and convenient wrapper around Apple's OSLog to provide structured and prefixed logging with emoji indicators.

import OSLog

/// A logger utility that provides easy-to-use methods for logging messages at different log levels,
/// including debug, info, warning, and error, with automatic file and line information.
public struct Logger: Sendable {
    private let logger: os.Logger
    private let prefix: String

    /// Creates a new `Logger` instance.
    ///
    /// - Parameters:
    ///   - prefix: An optional string to prefix each log message with, typically used to indicate a component or module.
    ///   - subsystem: The subsystem identifier used for the underlying OSLog, defaults to the current file path.
    public init(prefix: String = "", subsystem: String = #file) {
        logger = os.Logger(subsystem: subsystem, category: prefix)
        self.prefix = prefix
    }

    /// Logs a debug-level message.
    ///
    /// Use this method for verbose output useful during development and debugging.
    ///
    /// - Parameters:
    ///   - values: A variadic list of values to include in the log message.
    ///   - file: The file from which the logging method was called, defaults to the calling file.
    ///   - line: The line number from which the logging method was called, defaults to the calling line.
    public func debug(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.debug("\(createMessage(from: values, icon: .debug, file: file, line: line))")
    }

    /// Logs an info-level message.
    ///
    /// Use this method to report general information about app execution.
    ///
    /// - Parameters:
    ///   - values: A variadic list of values to include in the log message.
    ///   - file: The file from which the logging method was called, defaults to the calling file.
    ///   - line: The line number from which the logging method was called, defaults to the calling line.
    public func info(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.info("\(createMessage(from: values, icon: .info, file: file, line: line))")
    }

    /// Logs a warning-level message.
    ///
    /// Use this method to indicate potential issues or important situations that do not prevent normal execution.
    ///
    /// - Parameters:
    ///   - values: A variadic list of values to include in the log message.
    ///   - file: The file from which the logging method was called, defaults to the calling file.
    ///   - line: The line number from which the logging method was called, defaults to the calling line.
    public func warning(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.warning("\(createMessage(from: values, icon: .warning, file: file, line: line))")
    }

    /// Logs an error-level message.
    ///
    /// Use this method to report errors that require attention.
    ///
    /// - Parameters:
    ///   - values: A variadic list of values to include in the log message.
    ///   - file: The file from which the logging method was called, defaults to the calling file.
    ///   - line: The line number from which the logging method was called, defaults to the calling line.
    public func error(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        logger.error("\(createMessage(from: values, icon: .error, file: file, line: line))")
    }

    /// Builds the formatted log message string including icon, file name, line number, prefix, and the provided values.
    ///
    /// - Parameters:
    ///   - values: The array of values to include in the log message.
    ///   - icon: The icon representing the log level.
    ///   - file: The file from which the log was generated.
    ///   - line: The line number from which the log was generated.
    /// - Returns: A fully constructed log message string.
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

    /// Represents the emoji icons used to denote log levels visually.
    enum Icon: String {
        case debug = "🔷"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
    }
}
