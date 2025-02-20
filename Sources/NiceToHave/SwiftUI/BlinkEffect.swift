import SwiftUI

@available(macOS 13.0, *)
@available(iOS 17.0, *)
private struct BlinkViewModifier: ViewModifier {
    let duration: Double
    let speed: ContinuousClock.Instant.Duration
    @State private var blinking: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0 : 1)
            .task {
                await blink()
            }
    }

    func blink() async {
        let stream = AsyncStream<Void> {
            try? await Task.sleep(for: speed)
        }
        for try await _ in stream {
            blinking = !blinking
        }
    }
}

@available(macOS 13.0, *)
@available(iOS 17.0, *)
public extension View {
    func blinkEffect(duration: Double = 1, speed: ContinuousClock.Instant.Duration = .seconds(1)) -> some View {
        modifier(BlinkViewModifier(duration: duration, speed: speed))
    }
}
