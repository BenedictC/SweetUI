import Combine
import UIKit


//  MARK: - On Event

public extension SomeView where Self: UIControl {

    func onEvent(
        _ event: UIControl.Event,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared,
        perform handler: @escaping (Self) -> Void
    ) -> Self {
        let cancellable = addAction(for: event) { control, _ in
            handler(control)
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}
