import UIKit
import Combine


// MARK: - Text

public extension UILabel {

    convenience init<P: Publisher>(
        text publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where P.Output == String, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageHandler(cancellable, self)
    }

    convenience init<P: Publisher>(
        text publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where P.Output == String?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageHandler(cancellable, self)
    }

    func text<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == String, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }

    func text<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == String?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


// MARK: - AttributedText

public extension UILabel {

    convenience init<P: Publisher>(
        attributedText publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where P.Output == NSAttributedString, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageHandler(cancellable, self)
    }

    convenience init<P: Publisher>(
        attributedText publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where P.Output == NSAttributedString?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        //_ = self.assign(to: \.attributedText, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageHandler(cancellable, self)
    }

    func attributedText<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == NSAttributedString, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }

    func attributedText<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == NSAttributedString?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
