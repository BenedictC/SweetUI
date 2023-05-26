import UIKit


final public class NavigationController<Root: UIViewController>: FlowController {

    public let rootViewController: Root

    public init(rootViewController: Root) {
        self.rootViewController = rootViewController
    }
}

extension NavigationController: Presentable where Root: Presentable {

    public func resultForCancelledPresentation() -> Result<Root.Success, Error> {
        rootViewController.resultForCancelledPresentation()
    }
}
