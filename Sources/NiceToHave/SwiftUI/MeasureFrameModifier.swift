import Foundation
import SwiftUI

public struct MeasureFrameModifier: ViewModifier {
    public let coordinateSpace: CoordinateSpace
    public let onChange: (CGRect) -> Void

    public func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geo -> Color in
                    Task { @MainActor in
                        self.onChange(geo.frame(in: coordinateSpace))
                    }
                    return .clear
                }
            }
    }
}

public extension View {
    func measureFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (CGRect) -> Void) -> some View {
        modifier(MeasureFrameModifier(coordinateSpace: coordinateSpace, onChange: onChange))
    }
}
