import UIKit


@resultBuilder
public struct ArrangedSubviewsBuilder {

    public static func buildExpression(_ expression: UIView) -> [UIView] {
        [expression]
    }

    public static func buildExpression(_ expression: [UIView]) -> [UIView] {
        expression
    }

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.reduce([], +)
    }

    public static func buildArray(_ components: [[UIView]]) -> [UIView] {
        components.reduce([], +)
    }

    public static func buildOptional(_ component: [UIView]?) -> [UIView] {
        component ?? []
    }

    public static func buildEither(first component: [UIView]) -> [UIView] {
        component
    }

    public static func buildEither(second component: [UIView]) -> [UIView] {
        component
    }
}
