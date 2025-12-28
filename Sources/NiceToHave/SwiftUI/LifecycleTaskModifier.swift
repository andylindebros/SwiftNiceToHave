import SwiftUI

#if os(iOS)
private struct LifecycleTaskModifier: ViewModifier {
    @State private var appInForeground: Bool = true
    let action: @MainActor () async -> Void

    func body(content: Content) -> some View {
        content
            .task(id: appInForeground) {
                guard appInForeground else { return }
                await action()
            }
            .onAppDidBecomeActive {
                appInForeground = true
            }
            .onAppDidEnterBackground {
                appInForeground = false
            }
    }
}

public extension View {
    func lifecycleTask(action: @escaping @MainActor () async -> Void) -> some View {
        modifier(LifecycleTaskModifier(action: action))
    }
}

#endif
