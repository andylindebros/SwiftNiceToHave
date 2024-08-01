import Foundation
import SwiftUI

public extension View {
    func onInScreenEvent(onChange: @escaping (Bool) -> Void) -> some View {
        overlay(Color.clear.modifier(InScreenEventModifier(onChange: onChange)))
    }
}

struct InScreenEventModifier: ViewModifier {
    var onChange: (Bool) -> Void

    @State private var isInScreen: Bool = false

    private static let screenHeight = UIScreen.main.bounds.height

    func body(content _: Content) -> some View {
        GeometryReader { geo -> Color in
            let frame = geo.frame(in: .global)
            let isInScreen = frame.minY < Self.screenHeight && frame.maxY > 0
            if self.isInScreen != isInScreen {
                DispatchQueue.main.async {
                    self.isInScreen = isInScreen
                    onChange(isInScreen)
                }
            }
            return Color.clear
        }
    }
}
