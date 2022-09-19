import UIKit
import Combine


// MARK: - CancellablesStorageProvider continuous

public extension SomeView where Self: UITextField {

    func bindText<C: CancellablesStorageProvider, S: Subject>(to subscriberFactory: SubscriberFactory<C, S>) -> Self where S.Output == String?, S.Failure == Never {
        subscriberFactory.makeCancellable { subscribeAndSendText(to: $0) }
        return self
    }

    func bindAttributedText<C: CancellablesStorageProvider, S: Subject>(to subscriberFactory: SubscriberFactory<C, S>) -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        subscriberFactory.makeCancellable { subscribeAndSendAttributedText(to: $0) }
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
        // TODO: Add support for begin & end editing synchronization behaviour
        let send = self.addAction(for: .editingChanged) { textField, _ in
            subject.send(textField[keyPath: keyPath])
        }
        let receive = subject.sink { [weak self] value in
            guard let self = self else { return }
            if self.isFirstResponder { return }
            self[keyPath: keyPath] = value
        }
        return AnyCancellable {
            send.cancel()
            receive.cancel()
        }
    }
}
