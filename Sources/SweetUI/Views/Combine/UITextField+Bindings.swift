import UIKit
import Combine


// MARK: - CancellablesStorageProvider continuous

public extension SomeView where Self: UITextField {

    func bindText<S: Subject>(
        to subject: S,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store)
    -> Self where S.Output == String?, S.Failure == Never {
        let cancellable = subscribeAndSendText(to: subject)
        cancellableStorageHandler(cancellable, self)
        return self
    }
    
    func bindAttributedText<S: Subject>(
        to subject: S,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store)
    -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        let cancellable = subscribeAndSendAttributedText(to: subject)
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


// MARK: - Core binding creation

private extension SomeView where Self: UITextField {

    func subscribeAndSendText<S: Subject>(to subject: S) -> AnyCancellable where S.Output == String?, S.Failure == Never {
       return makeBindings(for: subject, keyPath: \.text)
    }

    func subscribeAndSendAttributedText<S: Subject>(to subject: S) -> AnyCancellable where S.Output == NSAttributedString?, S.Failure == Never {
        makeBindings(for: subject, keyPath: \.attributedText)
    }

    func makeBindings<V, S: Subject>(for subject: S, keyPath: ReferenceWritableKeyPath<Self, V>) -> AnyCancellable where S.Output == V, S.Failure == Never {
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
            if self.isFirstResponder { return }
            self[keyPath: keyPath] = value
        }
        return AnyCancellable {
            editingDidEnd.cancel()
            send.cancel()
            receive.cancel()
        }
    }
}
