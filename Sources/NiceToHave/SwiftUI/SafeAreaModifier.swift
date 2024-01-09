import Foundation
import SwiftUI

#if canImport(UIKit)
    public extension View {
        @MainActor func safeAreaPadding() -> some View {
            modifier(SafeAreaPaddingModifier())
        }
    }

    private struct SafeAreaPaddingModifier: ViewModifier {
        @MainActor init() {
            safeAreaInsets = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }?
                .safeAreaInsets ?? .zero
        }

        let safeAreaInsets: UIEdgeInsets

        func body(content: Content) -> some View {
            content
                .padding(.top, safeAreaInsets.top)
                .padding(.bottom, safeAreaInsets.bottom)
        }
    }
#endif
