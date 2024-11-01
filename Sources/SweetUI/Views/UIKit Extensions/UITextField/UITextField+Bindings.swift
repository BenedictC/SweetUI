import UIKit
import Combine

// TODO: Add variants for non-optional subjects (String? & NSAttributedString?)


// MARK: - Init

@MainActor
public extension SomeView where Self: UITextField {
    
    func text<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption = []
    ) -> Self where S.Output == String?, S.Failure == Never {
        bindText(to: subject, options: options).store(in: .current)
        return self
    }
    
    func attributedText<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption = []
    ) -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        bindAttributedText(to: subject, options: options).store(in: .current)
        return self
    }
    
    func text<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption = []
    ) -> Self where S.Output == String, S.Failure == Never {
        bindText(to: subject, options: options).store(in: .current)
        return self
    }
    
    func attributedText<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption = []
    ) -> Self where S.Output == NSAttributedString, S.Failure == Never {
        bindAttributedText(to: subject, options: options).store(in: .current)
        return self
    }
}


// MARK: - Initializers

public extension UITextField {
    
    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = []
    ) where S.Output == String?, S.Failure == Never {
        self.init()
        _ = self.text(bindsTo: subject, options: options)
    }
    
    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = []
    ) where S.Output == NSAttributedString?, S.Failure == Never {
        self.init()
        _ = self.attributedText(bindsTo: subject, options: options)
    }
    
    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = []
    ) where S.Output == String, S.Failure == Never {
        self.init()
        _ = self.text(bindsTo: subject, options: options)
    }
    
    convenience init<S: Subject>(
        text subject: S,
        options: UITextInputBindingOption = []
    ) where S.Output == NSAttributedString, S.Failure == Never {
        self.init()
        _ = self.attributedText(bindsTo: subject, options: options)
    }
}


// MARK: - Core binding creation

private extension SomeView where Self: UITextField {
    
    func bindText<S: Subject>(to subject: S, options: UITextInputBindingOption = []) -> AnyCancellable where S.Output == String?, S.Failure == Never {
        return makeBindings(for: subject, keyPath: \.text, options: options)
    }
    
    func bindAttributedText<S: Subject>(to subject: S, options: UITextInputBindingOption = []) -> AnyCancellable where S.Output == NSAttributedString?, S.Failure == Never {
        makeBindings(for: subject, keyPath: \.attributedText, options: options)
    }
    
    func bindText<S: Subject>(to subject: S, options: UITextInputBindingOption = []) -> AnyCancellable where S.Output == String, S.Failure == Never {
        return makeBindings(for: subject, keyPath: \.text, defaultValue: "", options: options)
    }
    
    func bindAttributedText<S: Subject>(to subject: S, options: UITextInputBindingOption = []) -> AnyCancellable where S.Output == NSAttributedString, S.Failure == Never {
        makeBindings(for: subject, keyPath: \.attributedText, defaultValue: NSAttributedString(string: ""), options: options)
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
    
    func makeBindings<V, S: Subject>(for subject: S, keyPath: ReferenceWritableKeyPath<Self, V?>, defaultValue: V, options: UITextInputBindingOption) -> AnyCancellable where S.Output == V, S.Failure == Never {
        let send = self.addAction(for: .editingChanged) { textField, _ in
            subject.send(textField[keyPath: keyPath] ?? defaultValue)
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
