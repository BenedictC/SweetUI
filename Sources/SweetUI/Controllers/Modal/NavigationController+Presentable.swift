import UIKit


final public class NavigationController<Root: UIViewController>: FlowController {

    public let rootViewController: Root

    public init(rootViewController: Root) {
        self.rootViewController = rootViewController
        super.init()
    }

    public init(
        @NavigationControllerStackBuilder<Root> rootViewController builder: () -> (Root, [UIViewController]))
    {
        let (root, others) = builder()
        self.rootViewController = root
        super.init()

        containerViewController.setViewControllers([root] + others, animated: false)
        containerViewController.setToolbarHidden(true, animated: false)
    }
}


extension NavigationController: Presentable where Root: Presentable {

    public func resultForCancelledPresentation() -> Result<Root.Success, Error> {
        rootViewController.resultForCancelledPresentation()
    }
}


@resultBuilder
public struct NavigationControllerStackBuilder<Root: UIViewController> {

    public static func buildBlock(_ root: Root) -> (Root, [UIViewController]) {
        return (root, [])
    }

    public static func buildBlock(_ root: Root, _ others: UIViewController...) -> (Root, [UIViewController]) {
        return (root, others)
    }
}
