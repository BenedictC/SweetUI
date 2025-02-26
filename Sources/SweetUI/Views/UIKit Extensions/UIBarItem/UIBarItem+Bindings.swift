import UIKit
import Combine


// MARK: Properties

public extension UIBarItem {
    
    func enabled(_ value: Bool) -> Self {
        isEnabled = value
        return self
    }
    
    func enabled(_ publisher: some Publisher<Bool, Never>) -> Self {
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
    
    func title(_ publisher: some Publisher<String?, Never>) -> Self {
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
    
    func image(_ publisher: some Publisher<UIImage?, Never>) -> Self {
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
