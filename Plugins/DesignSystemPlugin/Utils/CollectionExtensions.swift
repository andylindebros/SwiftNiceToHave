import Foundation

internal extension Collection {
    func chunks(ofSize size: Int) -> [SubSequence] {
        guard !isEmpty else { return [] }
        return [prefix(size)] + dropFirst(size).chunks(ofSize: size)
    }
}
