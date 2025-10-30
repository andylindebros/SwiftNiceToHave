import SwiftUI
import NiceToHave

struct ContentView: View {
    @State private var viewModel = ViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button(action: {
                Task {
                    await viewModel.onChange(of: [
                        "Andy", "Carita", "Ruby", "Henry", "Florence"
                    ].randomElement()!)
                }
            }) {
                Text("Tap me")
            }

            Button(action: {
                Task {
                    await viewModel.addName([
                        "Andy", "Carita", "Ruby", "Henry", "Florence"
                    ].randomElement()!)
                }
            }) {
                Text("Queue event")
            }
        }
        .padding()
    }
}

@MainActor
@Observable final class ViewModel {
    init() {
        throttler = Throttler<String>(interval: .milliseconds(250))
        debouncer = Debounce<String>(timeout: .milliseconds(250)) { [weak self] value in
            await self?.debouncedValue(value: value)
        }

        Task.detached { [weak self] in
            await self?.streamThrottler()
        }
    }

    private var debouncer: Debounce<String>?
    private let throttler: Throttler<String>

    func streamThrottler() async {
        for await name in throttler {
            print("🔥 Hello", "\(name)!")
        }
    }
    func debouncedValue(value: String) async {
        print("🚀 Hello", "\(value)!")
    }

    func onChange(of text: String) async {
        await debouncer?.emit(text)
    }

    func addName(_ name: String) async {
        await throttler.add(name)
    }
}

#Preview {
    ContentView()
}
