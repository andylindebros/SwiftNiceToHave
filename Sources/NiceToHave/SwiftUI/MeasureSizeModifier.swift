import Foundation
import SwiftUI

public struct MeasureSizeModifier: ViewModifier {
    public let onChange: (CGSize) -> Void

    public func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async {
                        self.onChange(geo.size)
                    }
                    return .clear
                }
            }
    }
}

public extension View {
    func measureSize(onChange: @escaping (CGSize) -> Void) -> some View {
        modifier(MeasureSizeModifier(onChange: onChange))
    }
}
