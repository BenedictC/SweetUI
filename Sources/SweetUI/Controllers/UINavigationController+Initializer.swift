import UIKit


public extension UINavigationController {

    convenience init(@NavigationStackBuilder<UIViewController> controllers stackBuilder: () -> (UIViewController, [UIViewController])) {
        let (root, stack) = stackBuilder()
        self.init()
        self.setViewControllers([root] + stack, animated: false)
    }
}


@resultBuilder
public struct NavigationStackBuilder<Root: UIViewController> {

    public static func buildBlock(_ root: Root) -> (Root, [UIViewController]) {
        return (root, [])
    }

    public static func buildBlock(_ root: Root, _ others: UIViewController...) -> (Root, [UIViewController]) {
        return (root, others)
    }
}
