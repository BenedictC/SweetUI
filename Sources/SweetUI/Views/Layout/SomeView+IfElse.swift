import Foundation
import UIKit


public extension SomeView where Self: UIView {

    // If the closures return differing types then the return value will be erased to UIView
    func `if`<T>(_ value: Bool, then ifTransform: (Self) -> T, `else` elseTransform: (Self) -> T) -> T {
        value ? ifTransform(self) : elseTransform(self)
    }

    func `if`(_ value: Bool, then transform: (Self) -> Self) -> Self {
        value ? transform(self) : self
    }

    // If the closure returns a different type then we have to erase to UIView.
    // If it is necessary to return a more specific type then add an else clause that explicitly states the type.
    func `if`(_ value: Bool, then transform: (Self) -> UIView) -> UIView {
        value ? transform(self) : self
    }
}
