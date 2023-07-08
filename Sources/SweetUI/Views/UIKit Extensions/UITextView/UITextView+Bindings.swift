import UIKit
import Combine


// MARK: - Modifiers

public extension SomeView where Self: UITextView {

    func text<S: Subject>(
        _ subject: S,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    )
    -> Self where S.Output == String?, S.Failure == Never {
        let cancellable = subscribeAndSendText(to: subject)
        cancellableStorageHandler(cancellable, self)
        return self
    }

    func attributedText<S: Subject>(
        _ subject: S,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    )
    -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        let cancellable = subscribeAndSendAttributedText(to: subject)
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


// MARK: - Initializers

public extension UITextView {

    convenience init<S: Subject>(
        text subject: S,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where S.Output == String?, S.Failure == Never {
        self.init()
        _ = self.text(subject, cancellableStorageHandler: cancellableStorageHandler)
    }

    convenience init<S: Subject>(
        text subject: S,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where S.Output == NSAttributedString?, S.Failure == Never {
        self.init()
        _ = self.attributedText(subject, cancellableStorageHandler: cancellableStorageHandler)
    }
}


// MARK: - Core binding creation

private extension SomeView where Self: UITextView {

    func subscribeAndSendText<S: Subject>(to subject: S) -> AnyCancellable where S.Output == String?, S.Failure == Never {
       return makeBindings(for: subject, keyPath: \.text)
    }

    func subscribeAndSendAttributedText<S: Subject>(to subject: S) -> AnyCancellable where S.Output == NSAttributedString?, S.Failure == Never {
        makeBindings(for: subject, keyPath: \.attributedText)
    }

    func makeBindings<V, S: Subject>(for subject: S, keyPath: ReferenceWritableKeyPath<Self, V>) -> AnyCancellable where S.Output == V, S.Failure == Never {
        // TODO: Add support for begin & end editing synchronization behaviour
        let send = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self, queue: nil) { notification in
            guard let textView = notification.object as? Self  else {
                return
            }
            let value = textView[keyPath: keyPath]
            subject.send(value)
        }
        let receive = subject.sink { value in
            if self.isFirstResponder { return }
            self[keyPath: keyPath] = value
        }
        return AnyCancellable {
            NotificationCenter.default.removeObserver(send)
            receive.cancel()
        }
    }
}
