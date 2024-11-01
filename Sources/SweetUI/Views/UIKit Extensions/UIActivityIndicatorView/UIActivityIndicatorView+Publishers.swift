import UIKit
import Combine


public extension UIActivityIndicatorView {
    
    convenience init<P: Publisher>(
        style: UIActivityIndicatorView.Style,
        isActive publisher: P
    ) where P.Output == Bool, P.Failure == Never {
        self.init(style: style)
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        //_ = self.active(publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.isActive = value
        }
        .store(in: CancellableStorage.current)
    }
    
    func active<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isActive, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.isActive = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
}
