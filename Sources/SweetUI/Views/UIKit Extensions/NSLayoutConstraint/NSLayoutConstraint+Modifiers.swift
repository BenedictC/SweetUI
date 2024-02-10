import Foundation
import UIKit


public extension UILayoutPriority {

    static let almostRequired = UILayoutPriority(rawValue: 999)
    static let lowest = UILayoutPriority(rawValue: 1)
}


public extension NSLayoutConstraint {

    func active(_ value: Bool) -> Self {
        self.isActive = value
        return self
    }

    func constant(_ value: CGFloat) -> Self {
        self.constant = value
        return self
    }

    func identifier(_ value: String?) -> Self {
        self.identifier = value
        return self
    }

    func priority(_ value: UILayoutPriority) -> Self {
        self.priority = value
        return self
    }
}
