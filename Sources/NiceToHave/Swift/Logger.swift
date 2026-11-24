/// A simple and convenient wrapper around Apple's OSLog to provide structured and prefixed logging with emoji indicators.

import OSLog

public extension NiceToHave {
    protocol Logger: Sendable {
        func debug(_ values: Any?..., file: StaticString, line: UInt)
        func info(_ values: Any?..., file: StaticString, line: UInt)
        func warning(_ values: Any?..., file: StaticString, line: UInt)
        func error(_ values: Any?..., file: StaticString, line: UInt)
    }

    /// A logger utility that provides easy-to-use methods for logging messages at different log levels,
    /// including debug, info, warning, and error, with automatic file and line information.
    struct LoggerImpl: NiceToHave.Logger {
        private let logger: os.Logger
        private let prefix: String
        private let crashlyticsLogger: CrashlyticsLogger?

        /// Creates a new `Logger` instance.
        ///
        /// - Parameters:
        ///   - prefix: An optional string to prefix each log message with, typically used to indicate a component or module.
        ///   - subsystem: The subsystem identifier used for the underlying OSLog, defaults to the current file path.
        public init(prefix: String = "", subsystem: String = #file, crashlyticsLogger: CrashlyticsLogger? = nil) {
            logger = os.Logger(subsystem: subsystem, category: prefix)
            self.prefix = prefix
            self.crashlyticsLogger = crashlyticsLogger
        }

        /// Logs a debug-level message.
        ///
        /// Use this method for verbose output useful during development and debugging.
        ///
        /// - Parameters:
        ///   - values: A variadic list of values to include in the log message.
        ///   - file: The file from which the logging method was called, defaults to the calling file.
        ///   - line: The line number from which the logging method was called, defaults to the calling line.
        public func debug(_ values: Any?..., file: StaticString, line: UInt) {
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
        public func info(_ values: Any?..., file: StaticString, line: UInt) {
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
        public func warning(_ values: Any?..., file: StaticString, line: UInt) {
            let message = createMessage(from: values, icon: .warning, file: file, line: line)

            logger.warning("\(message)")

            crashlyticsLog(
                level: .warning,
                message: message,
                file,
                line
            )
        }

        /// Logs an error-level message.
        ///
        /// Use this method to report errors that require attention.
        ///
        /// - Parameters:
        ///   - values: A variadic list of values to include in the log message.
        ///   - file: The file from which the logging method was called, defaults to the calling file.
        ///   - line: The line number from which the logging method was called, defaults to the calling line.
        public func error(_ values: Any?..., file: StaticString, line: UInt) {
            let message = createMessage(from: values, icon: .error, file: file, line: line)
            logger.error("\(message)")

            crashlyticsLog(
                level: .warning,
                message: message,
                file,
                line
            )
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

        private func crashlyticsLog(level _: LogLevel, message: String, _ file: StaticString, _ line: UInt) {
            // Note! We have to throw an exception to be able to log the message in firebase.  Crashlytics.crashlytics() does not seem to work.
            guard crashlyticsLogger != nil else { return }
            Task { [weak crashlyticsLogger] in
                await crashlyticsLogger?.record(
                    .init(message: message, userInfo: ["file": "\(file)", "line": "\(line)"])
                )
            }
        }

        /// Represents the emoji icons used to denote log levels visually.
        enum Icon: String {
            case debug = "🔷"
            case info = "ℹ️"
            case warning = "⚠️"
            case error = "❌"
        }

        public enum LogLevel: String, Codable, Sendable, CaseIterable {
            case debug, notice, trace, info, warning, error, fault, critical
        }
    }
}

public extension NiceToHave.Logger {
    func debug(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        debug(values, file: file, line: line)
    }

    func info(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        info(values, file: file, line: line)
    }

    func warning(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        warning(values, file: file, line: line)
    }

    func error(_ values: Any?..., file: StaticString = #file, line: UInt = #line) {
        error(values, file: file, line: line)
    }
}

public extension NiceToHave {
    struct LoggerMock: NiceToHave.Logger {
        public init() {}
        public func debug(_ values: Any?..., file: StaticString, line: UInt) {}
        public func info(_ values: Any?..., file: StaticString, line: UInt) {}
        public func warning(_ values: Any?..., file: StaticString, line: UInt) {}
        public func error(_ values: Any?..., file: StaticString, line: UInt) {}
    }

    protocol CrashlyticsLogger: AnyObject, Sendable {
        func record(_ event: CrashlyticsLog) async
        func subscribe() async -> AsyncStream<CrashlyticsLog>
    }

    struct CrashlyticsLog: Sendable {
        public let message: String
        public let userInfo: [String: String]
    }

    actor CrashlyticsLoggerImpl: CrashlyticsLogger {
        public init() {}

        private var continuation: AsyncStream<CrashlyticsLog>.Continuation?
        public func record(_ event: CrashlyticsLog) async {
            continuation?.yield(event)
        }

        public func subscribe() async -> AsyncStream<CrashlyticsLog> {
            AsyncStream { continuation in
                Task { [weak self] in
                    await self?.setContinuation(to: continuation)
                }
            }
        }

        private func setContinuation(to newValue: AsyncStream<CrashlyticsLog>.Continuation) async {
            continuation = newValue
        }

        public func cancel() async {
            continuation?.finish()
        }
    }

    enum LogLevel: Int, Sendable, Equatable {
        case debug, info, warning, error

        public func canLog(_ level: LogLevel) -> Bool {
            level.rawValue >= self.rawValue
        }

        public func log(_ values: Any?..., with logger: NiceToHave.Logger?, file: StaticString, line: UInt, function: StaticString) {
            guard let logger else { return }
            switch self {
            case .debug:
                logger.debug(values, file: file, line: line)
            case .info:
                logger.info(values, file: file, line: line)
            case .warning:
                logger.warning(values, file: file, line: line)
            case .error:
                logger.error(values, file: file, line: line)
            }
        }
    }
}
