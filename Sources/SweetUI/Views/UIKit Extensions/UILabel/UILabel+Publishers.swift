import UIKit
import Combine


// MARK: - Text

public extension UILabel {
    
    convenience init<P: Publisher>(
        text publisher: P
    ) where P.Output == String, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.text = value
        }
        .store(in: CancellableStorage.current)
    }
    
    convenience init<P: Publisher>(
        text publisher: P
    ) where P.Output == String?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.text = value
        }
        .store(in: CancellableStorage.current)
    }
    
    func text<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == String, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.text = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
    
    func text<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == String?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.text = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
}


// MARK: - AttributedText

public extension UILabel {
    
    convenience init<P: Publisher>(
        attributedText publisher: P
    ) where P.Output == NSAttributedString, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        .store(in: CancellableStorage.current)
    }
    
    convenience init<P: Publisher>(
        attributedText publisher: P
    ) where P.Output == NSAttributedString?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        //_ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        .store(in: CancellableStorage.current)
    }
    
    func attributedText<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == NSAttributedString, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        .store(in: CancellableStorage.current)
        return self
    }
    
    
    func attributedText<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == NSAttributedString?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.attributedText = value
        }        
        .store(in: CancellableStorage.current)
        return self
    }
}
