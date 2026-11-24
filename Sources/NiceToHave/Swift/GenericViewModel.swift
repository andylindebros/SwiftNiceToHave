import SwiftUI

package extension NiceToHave {
    @MainActor @Observable final class GenericViewModel<Value: Sendable> {
        package init(initValue: Value) {
            value = initValue
        }

        package private(set) var value: Value

        package func setValue(to newValue: Value) async {
            value = newValue
        }
    }
}
