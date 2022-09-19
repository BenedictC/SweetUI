import Foundation
import UIKit
import SweetUI


class DemoFlowController: NavigationFlowController {

    lazy var rootViewController = UIViewController()
}


extension DemoFlowController {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == rootViewController {
            push(ExampleViewController(), animated: animated)
        }
    }
}
