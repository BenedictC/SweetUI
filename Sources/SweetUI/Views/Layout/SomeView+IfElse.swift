import Foundation
import UIKit


public extension SomeView where Self: UIView {

    // If the closures return differing types then the return value will be erased to UIView
    func `if`<T: UIView>(_ value: Bool, _ ifHandler: (Self) -> T, `else` elseHandler: (Self) -> T) -> T {
        value ? ifHandler(self) : elseHandler(self)
    }

    func `if`(_ value: Bool, _ ifHandler: (Self) -> Self) -> Self {
        value ? ifHandler(self) : self
    }

    // If the closure returns a different type then we have to erase to UIView
    func `if`(_ value: Bool, _ ifHandler: (Self) -> UIView) -> UIView {
        value ? ifHandler(self) : self
    }
}
