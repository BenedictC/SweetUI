import UIKit
import Combine


// MARK: - Text

public extension UILabel {

    convenience init<P: Publisher>(
        text publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) where P.Output == String, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
    }

    convenience init<P: Publisher>(
        text publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) where P.Output == String?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
    }

    func text<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == String, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }

    func text<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == String?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.text, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.text = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}


// MARK: - AttributedText

public extension UILabel {

    convenience init<P: Publisher>(
        attributedText publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) where P.Output == NSAttributedString, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
    }

    convenience init<P: Publisher>(
        attributedText publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) where P.Output == NSAttributedString?, P.Failure == Never {
        self.init()
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        //_ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
    }

    func attributedText<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == NSAttributedString, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }

    func attributedText<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == NSAttributedString?, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // _ = self.assign(to: \.attributedText, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.attributedText = value
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}
