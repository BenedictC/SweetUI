import Foundation
import UIKit


// MARK: - NavigationFlowController

public typealias NavigationFlowController = _NavigationFlowController & NavigationFlowControllerRequirements


// MARK: - Associated Types

public protocol NavigationFlowControllerRequirements: _NavigationFlowControllerRequirements, FlowControllerRequirements where ContainerViewController: UINavigationController {
    associatedtype RootViewController: UIViewController

    var rootViewController: RootViewController { get }
}


public protocol _NavigationFlowControllerRequirements: _NavigationFlowController, _FlowControllerRequirements {
    var _rootViewController: UIViewController { get }
    var _containerViewController: UINavigationController { get }
}


// MARK: - Implementation

public extension NavigationFlowControllerRequirements {
    var _rootViewController: UIViewController { rootViewController }
    var _containerViewController: UINavigationController { containerViewController }
}


open class _NavigationFlowController: _FlowController {

    lazy var defaultNavigationController = UINavigationController()

    public override init() {
        super.init()
        guard let owner = self as? _NavigationFlowControllerRequirements else {
            preconditionFailure("_NavigationFlowController must conform to _NavigationFlowControllerRequirements")
        }
        owner._containerViewController.view.backgroundColor = .systemBackground
        owner._containerViewController.pushViewController(owner._rootViewController, animated: false)
    }
}


public extension NavigationFlowControllerRequirements {

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
