import Foundation
import UIKit


public extension UILayoutPriority {

    static let almostRequired = UILayoutPriority(rawValue: 999)
    static let lowest = UILayoutPriority(rawValue: 1)
}


public extension NSLayoutConstraint {

    func priority(_ value: UILayoutPriority) -> Self {
        self.priority = value
        return self
    }
}
