import Foundation
import UIKit


internal extension NSNotification.Name {
    static let viewDidAppear = Self("sweetUI.UIView.didAppear")
}


public extension UIView {

    func onDidAppear(
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared,
        handler: @escaping (Self) -> Void
    ) -> Self {
        let observer = NotificationCenter.default.addObserver(
            forName: .viewDidAppear,
            object: nil,
            queue: nil) { [weak self] notification in
                guard
                    let sendingViewController = notification.object as? UIViewController,
                    let self else { return }

                var next = self.next
                while let current = next {
                    guard let containingVC = current as? UIViewController else {
                        next = current.next
                        continue
                    }
                    let isMatch = containingVC == sendingViewController
                    guard isMatch else { return }
                    handler(self)
                    return
                }
                // No view controller found in the responder chain. Very strange.
            }
        let cancellable = AnyCancellable { NotificationCenter.default.removeObserver(observer) }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}
