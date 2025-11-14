import Foundation

@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildEither(first component: [Element]) -> [Element] {
        return component
    }

    public static func buildEither(second component: [Element]) -> [Element] {
        return component
    }

    public static func buildOptional(_ component: [Element]?) -> [Element] {
        return component ?? []
    }

    public static func buildExpression(_ expression: Element) -> [Element] {
        return [expression]
    }

    public static func buildExpression(_: ()) -> [Element] {
        return []
    }

    public static func buildBlock(_ components: [Element]...) -> [Element] {
        return components.flatMap { $0 }
    }

    public static func buildArray(_ components: [[Element]]) -> [Element] {
        Array(components.joined())
    }
}

public extension Array {
    init(@ArrayBuilder<Element> _ items: () -> [Element]) {
        self.init(items())
    }
}
