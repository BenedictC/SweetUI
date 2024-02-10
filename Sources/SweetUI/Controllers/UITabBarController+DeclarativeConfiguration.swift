import UIKit


public extension UITabBarController {

    convenience init(
        delegate: UITabBarControllerDelegate? = DefaultTabBarControllerDelegate.shared,
        @ArrayBuilder<UIViewController> childViewControllers builder: () -> [UIViewController])
    {
        self.init()
        self.delegate = delegate
        let childViewControllers = builder()
        self.setViewControllers(childViewControllers, animated: false)
    }
}


// MARK: - DefaultTabBarControllerDelegate

public final class DefaultTabBarControllerDelegate: NSObject, UITabBarControllerDelegate {

    public static let shared = DefaultTabBarControllerDelegate()

    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard
            // If tab is already selected...
            tabBarController.selectedViewController == viewController,
            // ... And it is a flow controller with a nav as the container ..
            let flowController = viewController as? _FlowController,
            let nestedNav = flowController.children.first as? UINavigationController
        else {
            return true
        }
        // ... then pop to root
        nestedNav.popToRootViewController(animated: true)
        return true
    }

    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        fixTruncatedChildFrameCausedByNonTranslucentTabBar(in: tabBarController)
    }

    private func fixTruncatedChildFrameCausedByNonTranslucentTabBar(in tabBarController: UITabBarController) {
        guard !tabBarController.tabBar.isTranslucent else {
            return
        }
        tabBarController.tabBar.isTranslucent = true
        tabBarController.view.setNeedsLayout()
        tabBarController.view.layoutIfNeeded()
        tabBarController.tabBar.isTranslucent = false
    }
}
