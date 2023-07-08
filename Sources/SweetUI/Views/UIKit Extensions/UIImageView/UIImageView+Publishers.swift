import UIKit
import Combine


// MARK: - Modifiers

public extension UIImageView {

    convenience init<P: Publisher>(
        image publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where P.Output == UIImage, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.image, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.image = value
        }
        cancellableStorageHandler(cancellable, self)
    }

    convenience init<P: Publisher>(
        image publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where P.Output == UIImage?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.image, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.image = value
        }
        cancellableStorageHandler(cancellable, self)
    }

    func image<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == UIImage, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.image, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.image = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }

    func image<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == UIImage?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.image, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.image = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
