import UIKit
import Combine


// MARK: - Modifiers

public extension UIView {

    func hidden<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isHidden = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }

    func alpha<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == CGFloat, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.alpha, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.alpha = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
