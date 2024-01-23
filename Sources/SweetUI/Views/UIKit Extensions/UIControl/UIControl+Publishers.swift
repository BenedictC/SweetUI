import UIKit
import Combine


// MARK: - Modifiers

public extension UIControl {

    func enabled<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isEnabled, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isEnabled = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }

    func selected<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isSelected, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isSelected = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }

    func highlighted<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHighlighted, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isHighlighted = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}
