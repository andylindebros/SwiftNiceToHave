import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#endif

#if canImport(UIKit)
@MainActor public protocol UIApplicationProvider {
    func registerForRemoteNotifications()
    func unregisterForRemoteNotifications()
    func canOpenURL(_ url: URL) -> Bool
    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler: ((Bool) -> Void)?)
    func hideKeyboard()
    var shortcutItems: [UIApplicationShortcutItem]? { get set }
}

public extension UIApplicationProvider {
    @MainActor func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completionHandler: ((Bool) -> Void)? = nil) {
        open(url, options: options, completionHandler: completionHandler)
    }
}

extension UIApplication: UIApplicationProvider {
    public func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

@MainActor class UIApplicationMock: UIApplicationProvider, @unchecked Sendable, ObservableObject {
    @Published private(set) var events = [Event]()
    func reset() {
        Task { @MainActor in
            events = []
        }
    }

    enum Event {
        case registerForRemoteNotifications
        case unregisterForRemoteNotifications
    }

    func registerForRemoteNotifications() {
        Task { @MainActor in
            events.append(.registerForRemoteNotifications)
        }
    }

    func unregisterForRemoteNotifications() {
        Task { @MainActor in
            events.append(.unregisterForRemoteNotifications)
        }
    }

    func canOpenURL(_: URL) -> Bool {
        return true
    }

    func open(_: URL, options _: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler _: ((Bool) -> Void)?) {}

    public func hideKeyboard() {}

    var shortcutItems: [UIApplicationShortcutItem]?
}
#endif
