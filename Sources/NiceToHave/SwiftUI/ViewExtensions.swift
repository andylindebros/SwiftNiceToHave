import Foundation
import SwiftUI


public extension View {
    func frame(_ value: CGFloat) -> some View {
        frame(width: value, height: value)
    }

    func frame(_ width: CGFloat, _ height: CGFloat) -> some View {
        frame(width: width, height: height)
    }

    func height(_ value: CGFloat) -> some View {
        frame(height: value)
    }

    func width(_ value: CGFloat) -> some View {
        frame(width: value)
    }

    func maxHeight(_ value: CGFloat) -> some View {
        frame(maxHeight: value)
    }

    func maxWidth(_ value: CGFloat) -> some View {
        frame(maxWidth: value)
    }

    func padding(_ horizontal: CGFloat, _ vertical: CGFloat) -> some View {
        padding(.vertical, vertical).padding(.horizontal, horizontal)
    }
}

public extension View {
    func sync<T: Equatable>(_ binding: Binding<T>, with focusState: FocusState<T>) -> some View {
        onChange(of: binding.wrappedValue) {
            focusState.wrappedValue = $0
        }
        .onChange(of: focusState.wrappedValue) {
            binding.wrappedValue = $0
        }
    }
}

public extension View {
    var insets: UIEdgeInsets {
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }?
            .safeAreaInsets ?? .zero
    }
}
