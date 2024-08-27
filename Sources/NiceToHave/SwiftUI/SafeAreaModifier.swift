import Foundation
import SwiftUI

#if os(iOS)
import UIKit
#endif

#if canImport(UIKit)
    public extension View {
        @MainActor func paddingSafeArea(_ insets: Edge.Set = .all) -> some View {
            modifier(SafeAreaPaddingModifier(insets: insets))
        }
    }

    private struct SafeAreaPaddingModifier: ViewModifier {
        @MainActor init(insets: Edge.Set) {
            self.insets = insets
            safeAreaInsets = UIApplication
                .shared
                .connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }?
                .safeAreaInsets ?? .zero
        }
        let insets: Edge.Set
        let safeAreaInsets: UIEdgeInsets

        func body(content: Content) -> some View {
            content
                .if(insets.contains(.top)) { view in
                    view.padding(.top, safeAreaInsets.top)
                }
                .if(insets.contains(.bottom)) { view in
                    view.padding(.bottom, safeAreaInsets.bottom)
                }
                .if(insets.contains(.leading)) { view in
                    view.padding(.leading, safeAreaInsets.left)
                }
                .if(insets.contains(.trailing)) { view in
                    view.padding(.trailing, safeAreaInsets.right)
                }
                .padding(.bottom, safeAreaInsets.bottom)
        }
    }
#endif
