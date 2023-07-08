import UIKit
import Combine


public extension UIActivityIndicatorView {

    convenience init<P: Publisher>(
        style: UIActivityIndicatorView.Style,
        isActive publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where P.Output == Bool, P.Failure == Never {
        self.init(style: style)
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        //_ = self.active(publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isActive = value
        }
        cancellableStorageHandler(cancellable, self)
    }

    func active<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isActive, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isActive = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
