import UIKit
import Combine


// MARK: - Core binding creation

extension SomeView where Self: UITextField {

    public func subscribeAndSendText<S: Subject>(to subject: S) -> AnyCancellable where S.Output == String?, S.Failure == Never {
       return makeBindings(for: subject, keyPath: \.text)
    }

    public func subscribeAndSendAttributedText<S: Subject>(to subject: S) -> AnyCancellable where S.Output == NSAttributedString?, S.Failure == Never {
        makeBindings(for: subject, keyPath: \.attributedText)
    }

    func makeBindings<V, S: Subject>(for subject: S, keyPath: ReferenceWritableKeyPath<Self, V>) -> AnyCancellable where S.Output == V, S.Failure == Never {
        // TODO: Add support for begin & end editing synchronization behaviour
        let send = self.subscribeTo(.editingChanged) { textField in
            subject.send(textField[keyPath: keyPath])
        }
        let receive = subject.sink { value in
            if self.isFirstResponder { return }
            self[keyPath: keyPath] = value
        }
        return AnyCancellable {
            send.cancel()
            receive.cancel()
        }
    }
}


// MARK: - ViewIsAvailableProvider continuous

public extension SomeView where Self: UITextField {

    func bindText<P: ViewIsAvailableProvider, S: Subject>(handlerIdentifier: AnyHashable = UUID(), to provider: P, _ keyPath: KeyPath<P, S>) -> Self where S.Output == String?, S.Failure == Never {
        subscribeToViewIsAvailable(of: provider, handlerIdentifier: handlerIdentifier) { textField, provider in
            let subject = provider[keyPath: keyPath]
            return textField.makeBindings(for: subject, keyPath: \.text)
        }
    }

    func bindText<P: ViewIsAvailableProvider, S: Subject>(handlerIdentifier: AnyHashable = UUID(), to provider: P, builder: @escaping (Self, P) -> S) -> Self where S.Output == String?, S.Failure == Never {
        subscribeToViewIsAvailable(of: provider, handlerIdentifier: handlerIdentifier) { textField, provider in
            textField.makeBindings(for: builder(textField, provider), keyPath: \.text)
        }
    }

    func bindAttributedText<P: ViewIsAvailableProvider, S: Subject>(handlerIdentifier: AnyHashable = UUID(), to provider: P, _ keyPath: KeyPath<P, S>) -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        subscribeToViewIsAvailable(of: provider, handlerIdentifier: handlerIdentifier) { textField, provider in
            textField.makeBindings(for: provider[keyPath: keyPath], keyPath: \.attributedText)
        }
    }

    func bindAttributedText<P: ViewIsAvailableProvider, S: Subject>(handlerIdentifier: AnyHashable = UUID(), to provider: P, builder: @escaping (Self, P) -> S) -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        subscribeToViewIsAvailable(of: provider, handlerIdentifier: handlerIdentifier) { textField, provider in
            textField.makeBindings(for: builder(textField, provider), keyPath: \.attributedText)
        }
    }
}
