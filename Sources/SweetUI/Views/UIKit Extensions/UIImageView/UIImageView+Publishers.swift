import UIKit
import Combine


// MARK: - Modifiers

public extension UIImageView {
    
    convenience init<P: Publisher>(
        image publisher: P
    ) where P.Output == UIImage, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.image, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.image = value
        }
        .store(in: CancellableStorage.current)
    }
    
    convenience init<P: Publisher>(
        image publisher: P
    ) where P.Output == UIImage?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.image, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.image = value
        }
        .store(in: CancellableStorage.current)
    }
    
    func image<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == UIImage, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.image, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.image = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
    
    func image<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == UIImage?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.image, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.image = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
}
