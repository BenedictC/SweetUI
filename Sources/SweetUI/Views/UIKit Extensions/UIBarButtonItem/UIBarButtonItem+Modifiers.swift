import UIKit
import Combine


public extension UIBarButtonItem {

    func width(_ value: CGFloat) -> Self {
        width = value
        return self
    }

    func width<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == CGFloat, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.width = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


@available(iOS 14, *)
public extension UIBarButtonItem {

    func menu(_ value: UIMenu?) -> Self {
        menu = value
        title = menu?.title
        image = menu?.image
        return self
    }

    func menu<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == UIMenu?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            _ = self?.menu(value)
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


@available(iOS 15, *)
public extension UIBarButtonItem {

    func selected(_ value: Bool) -> Self {
        isSelected = value
        return self
    }

    func selected<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isSelected = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


@available(iOS 16, *)
public extension UIBarButtonItem {

    func hidden(_ value: Bool) -> Self {
        isHidden = value
        return self
    }

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
}
