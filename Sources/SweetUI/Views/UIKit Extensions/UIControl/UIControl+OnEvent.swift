import Combine
import UIKit


//  MARK: - On Event

public extension SomeView where Self: UIControl {

    func onEvent(
        _ event: UIControl.Event,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store,
        perform handler: @escaping (Self) -> Void
    ) -> Self {
        let cancellable = addAction(for: event) { control, _ in
            handler(control)
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
