import UIKit
import Combine


// MARK: Properties

public extension UIBarItem {
    
    func enabled(_ value: Bool) -> Self {
        isEnabled = value
        return self
    }
    
    func enabled<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.isEnabled = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
    
    func enabled(_ value: String?) -> Self {
        title = value
        return self
    }
    
    func title<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == String?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.title = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
    
    func image(_ value: UIImage?) -> Self {
        image = value
        return self
    }
    
    func image<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == UIImage?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.image = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
}
