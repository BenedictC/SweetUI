import UIKit
import Combine

// TODO: Add variants for non-optional subjects (String? & NSAttributedString?)


// MARK: - Init

public extension SomeView where Self: UITextField {

    func text<S: Subject>(
        _ subject: S,
        options: UITextInputBindingOption = [],
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where S.Output == String?, S.Failure == Never {
        let cancellable = bindText(to: subject, options: options)
        cancellableStorageHandler(cancellable, self)
        return self
    }

    func attributedText<S: Subject>(
        _ subject: S,
        options: UITextInputBindingOption = [],
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        let cancellable = bindAttributedText(to: subject, options: options)
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


// MARK: - Initializers

public extension UITextField {

    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = [],
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where S.Output == String?, S.Failure == Never {
        self.init()
        _ = self.text(subject, options: options, cancellableStorageHandler: cancellableStorageHandler)
    }

    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = [],
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) where S.Output == NSAttributedString?, S.Failure == Never {
        self.init()
        _ = self.attributedText(subject, options: options, cancellableStorageHandler: cancellableStorageHandler)
    }
}


// MARK: - Core binding creation

public extension SomeView where Self: UITextField {

    func bindText<S: Subject>(to subject: S, options: UITextInputBindingOption = []) -> AnyCancellable where S.Output == String?, S.Failure == Never {
        return makeBindings(for: subject, keyPath: \.text, options: options)
    }

    func bindAttributedText<S: Subject>(to subject: S, options: UITextInputBindingOption = []) -> AnyCancellable where S.Output == NSAttributedString?, S.Failure == Never {
        makeBindings(for: subject, keyPath: \.attributedText, options: options)
    }
}


private extension SomeView where Self: UITextField {

    func makeBindings<V, S: Subject>(for subject: S, keyPath: ReferenceWritableKeyPath<Self, V>, options: UITextInputBindingOption) -> AnyCancellable where S.Output == V, S.Failure == Never {
        let send = self.addAction(for: .editingChanged) { textField, _ in
            subject.send(textField[keyPath: keyPath])
        }
        let editingDidEnd = self.addAction(for: [.editingDidEnd]) { textField, event in
            // Changes from the subject are ignore while the textField has focus so
            // resynchronize the value when editing ends.
            _ = subject.sink { textField[keyPath: keyPath] = $0 }
        }
        let receive = subject.sink { [weak self] value in
            guard let self = self else { return }
            let shouldUpdate = !self.isFirstResponder || options.contains(.updatesTextWhenIsFirstResponder)
            guard shouldUpdate else { return }
            self[keyPath: keyPath] = value
        }
        return AnyCancellable {
            editingDidEnd.cancel()
            send.cancel()
            receive.cancel()
        }
    }
}
