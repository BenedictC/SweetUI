import Foundation
import UIKit


public typealias NavigationFlowController = _NavigationFlowController & NavigationFlowSupporting


public protocol NavigationFlowSupporting: _NavigationFlowSupporting, FlowSupporting where ContainerViewController: UINavigationController {

    associatedtype RootViewController: UIViewController

    var rootViewController: RootViewController { get }
}


public protocol _NavigationFlowSupporting: _FlowSupporting {
    var _rootViewController: UIViewController { get }
    var _containerViewController: UINavigationController { get }
}


public extension NavigationFlowSupporting {
    var _rootViewController: UIViewController { rootViewController }
    var _containerViewController: UINavigationController { containerViewController }
}


open class _NavigationFlowController: _FlowController {

    lazy var defaultNavigationController = UINavigationController()

    public override init() {
        super.init()
        guard let owner = self as? _NavigationFlowSupporting else {
            preconditionFailure("_NavigationFlowController must conform to _NavigationFlowSupporting")
        }
        owner._containerViewController.view.backgroundColor = .systemBackground
        owner._containerViewController.pushViewController(owner._rootViewController, animated: false)
    }
}


public extension NavigationFlowSupporting where Self: _NavigationFlowController {

    var containerViewController: UINavigationController { defaultNavigationController }

    func push(_ viewController: UIViewController, animated: Bool) {
        containerViewController.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool) {
        containerViewController.popViewController(animated: animated)
    }

    func pop(to child: UIViewController, animated: Bool) {
        containerViewController.popToViewController(child, animated: animated)
    }

    func popToRoot(animated: Bool) {
        containerViewController.popToRootViewController(animated: animated)
    }
}
