import Foundation
import UIKit


public extension UIButton {

    convenience init(title: String) {
        self.init()
        setTitle(title, for: .normal)
    }

    convenience init(image: UIImage) {
        self.init()
        setImage(image, for: .normal)
    }

    convenience init(systemImageName: String) {
        self.init()
        let image = UIImage(systemName: systemImageName)
        setImage(image, for: .normal)
    }
}

@available(iOS 15.0, *)
public extension UIButton.Configuration {

    func configure(using block: (inout Self) -> Void) -> Self {
        var config = self
        block(&config)
        return config
    }
}
