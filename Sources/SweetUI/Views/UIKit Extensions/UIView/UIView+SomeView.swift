import UIKit


extension UIView: SomeView { }


public extension SomeView {

    func configure(using closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}
