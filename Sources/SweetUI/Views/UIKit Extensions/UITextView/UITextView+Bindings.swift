import UIKit
import Combine


// MARK: - Modifiers

public extension SomeView where Self: UITextView {

    func text<S: Subject>(
        _ subject: S,
        options: UITextInputBindingOption,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    )
    -> Self where S.Output == String?, S.Failure == Never {
        let cancellable = subscribeAndSendText(to: subject, options: options)
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }

    func attributedText<S: Subject>(
        _ subject: S,
        options: UITextInputBindingOption,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    )
    -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        let cancellable = subscribeAndSendAttributedText(to: subject, options: options)
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}


// MARK: - Initializers

public extension UITextView {

    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = [],
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) where S.Output == String?, S.Failure == Never {
        self.init()
        _ = self.text(subject, options: options, cancellableStorageProvider: cancellableStorageProvider)
    }

    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = [],
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) where S.Output == NSAttributedString?, S.Failure == Never {
        self.init()
        _ = self.attributedText(subject, options: options, cancellableStorageProvider: cancellableStorageProvider)
    }
}


// MARK: - Core binding creation

private extension SomeView where Self: UITextView {

    func subscribeAndSendText<S: Subject>(to subject: S, options: UITextInputBindingOption) -> AnyCancellable where S.Output == String?, S.Failure == Never {
       return makeBindings(for: subject, options: options, keyPath: \.text)
    }

    func subscribeAndSendAttributedText<S: Subject>(to subject: S, options: UITextInputBindingOption) -> AnyCancellable where S.Output == NSAttributedString?, S.Failure == Never {
        makeBindings(for: subject, options: options, keyPath: \.attributedText)
    }

    func makeBindings<V, S: Subject>(for subject: S, options: UITextInputBindingOption, keyPath: ReferenceWritableKeyPath<Self, V>) -> AnyCancellable where S.Output == V, S.Failure == Never {
        // TODO: Add support for begin & end editing synchronization behaviour
        let send = NotificationCenter.default.addObserver(forName: UITextView.textDidChangeNotification, object: self, queue: nil) { notification in
            guard let textView = notification.object as? Self  else {
                return
            }
            let value = textView[keyPath: keyPath]
            subject.send(value)
        }
        let receive = subject.sink { value in
            let shouldUpdate = !self.isFirstResponder || options.contains(.updatesTextWhenIsFirstResponder)
            guard shouldUpdate else { return }
            // TODO: Maintain cursor/selection when isFirstResponder
            self[keyPath: keyPath] = value
        }
        return AnyCancellable {
            NotificationCenter.default.removeObserver(send)
            receive.cancel()
        }
    }
}
