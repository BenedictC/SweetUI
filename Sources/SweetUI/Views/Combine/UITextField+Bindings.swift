import UIKit
import Combine


// MARK: - Core binding creation

extension SomeView where Self: UITextField {

    public func subscribeAndSendText(to subject: CurrentValueSubject<String?, Never>) -> AnyCancellable {
       return makeBindings(for: subject, keyPath: \.text)
    }

    public func subscribeAndSendAttributedText(to subject: CurrentValueSubject<NSAttributedString?, Never>) -> AnyCancellable {
        makeBindings(for: subject, keyPath: \.attributedText)
    }

    func makeBindings<T>(for subject: CurrentValueSubject<T, Never>, keyPath: ReferenceWritableKeyPath<Self, T>) -> AnyCancellable {
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


// MARK: - ViewConnectionProvider continuous

public extension SomeView where Self: UITextField {

    func bindText<T: ViewConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, _ keyPath: KeyPath<T, CurrentValueSubject<String?, Never>>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, source in
            textField.makeBindings(for: source[keyPath: keyPath], keyPath: \.text)
        }
    }

    func bindText<T: ViewConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, builder: @escaping (Self, T) -> CurrentValueSubject<String?, Never>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, source in
            textField.makeBindings(for: builder(textField, source), keyPath: \.text)
        }
    }

    func bindAttributedText<T: ViewConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, _ keyPath: KeyPath<T, CurrentValueSubject<NSAttributedString?, Never>>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, source in
            textField.makeBindings(for: source[keyPath: keyPath], keyPath: \.attributedText)
        }
    }

    func bindAttributedText<T: ViewConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, builder: @escaping (Self, T) -> CurrentValueSubject<NSAttributedString?, Never>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, source in
            textField.makeBindings(for: builder(textField, source), keyPath: \.attributedText)
        }
    }
}


// MARK: - ViewModelConnectionProvider continuous

public extension SomeView where Self: UITextField {

    func bindText<T: ViewModelConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, _ keyPath: KeyPath<T.ViewModel, CurrentValueSubject<String?, Never>>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, _, viewModel in
            textField.makeBindings(for: viewModel[keyPath: keyPath], keyPath: \.text)
        }
    }

    func bindText<T: ViewModelConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, builder: @escaping (Self, T, T.ViewModel) -> CurrentValueSubject<String?, Never>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, source, viewModel in
            textField.makeBindings(for: builder(textField, source, viewModel), keyPath: \.text)
        }
    }

    func bindAttributedText<T: ViewModelConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, _ keyPath: KeyPath<T.ViewModel, CurrentValueSubject<NSAttributedString?, Never>>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, _, viewModel in
            textField.makeBindings(for: viewModel[keyPath: keyPath], keyPath: \.attributedText)
        }
    }

    func bindAttributedText<T: ViewModelConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, builder: @escaping (Self, T, T.ViewModel) -> CurrentValueSubject<NSAttributedString?, Never>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { textField, source, viewModel in
            textField.makeBindings(for: builder(textField, source, viewModel), keyPath: \.attributedText)
        }
    }
}
