@resultBuilder
public struct ArrayBuilder<Element> {

    public static func buildExpression(_ expression: Element?) -> [Element] {
        [expression].compactMap { $0 }
    }

    public static func buildExpression(_ expression: [Element]) -> [Element] {
        expression
    }

    public static func buildBlock(_ components: [Element]...) -> [Element] {
        components.reduce([], +)
    }

    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.reduce([], +)
    }

    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }

    public static func buildEither(first component: [Element]) -> [Element] {
        component
    }

    public static func buildEither(second component: [Element]) -> [Element] {
        component
    }
}
