import UIKit
import Combine


// MARK: - ViewIsAvailableProvider continuous

public extension SomeView where Self: UITextField {

    func bindText<A: ViewIsAvailableProvider, S: Subject>(to subjectParameter: ValueParameter<A, Self, S>) -> Self where S.Output == String?, S.Failure == Never {
        subjectParameter.context = self
        subjectParameter.invalidationHandler = { [weak subjectParameter] in
            guard let root = subjectParameter?.root else { return }
            guard let identifier = subjectParameter?.identifier else { return }
            root.removeViewIsAvailableHandler(forIdentifier: identifier)
        }
        subjectParameter.root?.addViewIsAvailableHandler(withIdentifier: subjectParameter.identifier) {
            guard let subject = subjectParameter.makeValue() else { return nil }
            return subjectParameter.context?.subscribeAndSendText(to: subject)
        }
        return self
    }

    func bindAttributedText<A: ViewIsAvailableProvider, S: Subject>(to subjectParameter: ValueParameter<A, Self, S>) -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        subjectParameter.context = self
        subjectParameter.invalidationHandler = { [weak subjectParameter] in
            guard let root = subjectParameter?.root else { return }
            guard let identifier = subjectParameter?.identifier else { return }
            root.removeViewIsAvailableHandler(forIdentifier: identifier)
        }
        subjectParameter.root?.addViewIsAvailableHandler(withIdentifier: subjectParameter.identifier) {
            guard let subject = subjectParameter.makeValue() else { return nil }
            return subjectParameter.context?.subscribeAndSendAttributedText(to: subject)
        }
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
