import Foundation

#if os(iOS)
    import UIKit
#endif
#if canImport(UIKit)
    public protocol UIApplicationProvider {
        @MainActor func canOpenURL(_ url: URL) -> Bool
        func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?)
        @discardableResult @MainActor func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool
        @MainActor var isIdleTimerDisabled: Bool { get set }
    }

    public extension UIApplicationProvider {
        func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completionHandler: ((Bool) -> Void)?) {
            open(url, options: options, completionHandler: completionHandler)
        }

        @discardableResult @MainActor func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:]) async -> Bool {
            return await open(url, options: options)
        }
    }

    // Since UIApplication.shared can return nil even though the singleton is granted, a wrapper is provided that can be used to inject as a dependency.
    struct UIApplicationWrapper: UIApplicationProvider {
        func canOpenURL(_ url: URL) -> Bool {
            UIApplication.shared.canOpenURL(url)
        }

        var isIdleTimerDisabled: Bool {
            didSet {
                UIApplication.shared.isIdleTimerDisabled = isIdleTimerDisabled
            }
        }

        func open(_ url: URL, options _: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool {
            await UIApplication.shared.open(url)
        }
    }

    extension UIApplication: UIApplicationProvider {}

    public final class UIApplicationMock: UIApplicationProvider {
        public init(isIdleTimerDisabled: Bool = false) {
            self.isIdleTimerDisabled = isIdleTimerDisabled
        }

        public private(set) var events: [Event] = []
        private var canOpenURLResponse = true
        private var openResponse = true

        public func canOpenURL(_ url: URL) -> Bool {
            events.append(.canOpenURL(url))
            return canOpenURLResponse
        }

        public func open(url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Bool {
            events.append(.open(url, options: options))
            return openResponse
        }

        public var isIdleTimerDisabled: Bool

        @discardableResult public func setCanOpenURLResponse(to value: Bool) -> Self {
            canOpenURLResponse = value
            return self
        }

        @discardableResult public func setOpenResponse(to value: Bool) -> Self {
            openResponse = value
            return self
        }

        public func reset() {
            events = []
        }

        public enum Event {
            case canOpenURL(URL)
            case open(URL, options: [UIApplication.OpenExternalURLOptionsKey: Any])
        }
    }
#endif
