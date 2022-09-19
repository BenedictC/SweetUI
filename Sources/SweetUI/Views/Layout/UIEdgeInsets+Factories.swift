import UIKit


public extension UIEdgeInsets {

    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        var insets = Self.zero
        insets.left = left
        insets.top = top
        insets.right = right
        insets.bottom = bottom
        self = insets
    }

    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        self.init(top: 0, left: value, bottom: 0, right: value)
    }

    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        self.init(top: value, left: 0, bottom: value, right: 0)
    }

    static func left(_ value: CGFloat) -> UIEdgeInsets { self.init(left: value) }
    static func top(_ value: CGFloat) -> UIEdgeInsets { self.init(top: value) }
    static func bottom(_ value: CGFloat) -> UIEdgeInsets { self.init(bottom: value) }
    static func right(_ value: CGFloat) -> UIEdgeInsets { self.init(right: value) }
}
