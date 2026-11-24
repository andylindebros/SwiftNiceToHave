import Foundation

@resultBuilder
package enum ArrayBuilder<Element> {
    package static func buildEither(first component: [Element]) -> [Element] {
        return component
    }

    package static func buildEither(second component: [Element]) -> [Element] {
        return component
    }

    package static func buildOptional(_ component: [Element]?) -> [Element] {
        return component ?? []
    }

    package static func buildExpression(_ expression: Element) -> [Element] {
        return [expression]
    }

    package static func buildExpression(_: ()) -> [Element] {
        return []
    }

    package static func buildBlock(_ components: [Element]...) -> [Element] {
        return components.flatMap { $0 }
    }

    package static func buildArray(_ components: [[Element]]) -> [Element] {
        Array(components.joined())
    }
}

package extension Array {
    init(@ArrayBuilder<Element> _ items: () throws -> [Element]) rethrows {
        self = try items()
    }

    init(@ArrayBuilder<Element> _ items: () async throws -> [Element]) async rethrows {
        self = try await items()
    }
}
