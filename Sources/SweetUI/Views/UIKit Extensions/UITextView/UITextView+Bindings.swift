import UIKit
import Combine


// MARK: - Modifiers

@MainActor
public extension SomeView where Self: UITextView {
    
    func text<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption
    )
    -> Self where S.Output == String?, S.Failure == Never {
        subscribeAndSendText(to: subject, options: options).store(in: .current)
        return self
    }
    
    func attributedText<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption
    )
    -> Self where S.Output == NSAttributedString?, S.Failure == Never {
        subscribeAndSendAttributedText(to: subject, options: options).store(in: .current)
        return self
    }
    
    func text<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption
    )
    -> Self where S.Output == String, S.Failure == Never {
        subscribeAndSendText(to: subject, options: options).store(in: .current)
        return self
    }
    
    func attributedText<S: Subject>(
        bindsTo subject: S,
        options: UITextInputBindingOption
    )
    -> Self where S.Output == NSAttributedString, S.Failure == Never {
        subscribeAndSendAttributedText(to: subject, options: options).store(in: .current)        
        return self
    }
}


// MARK: - Initializers

public extension UITextView {
    
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

private extension SomeView where Self: UITextView {
    
    func subscribeAndSendText<S: Subject>(to subject: S, options: UITextInputBindingOption) -> AnyCancellable where S.Output == String?, S.Failure == Never {
        return makeBindings(for: subject, options: options, keyPath: \.text)
    }
    
    func subscribeAndSendAttributedText<S: Subject>(to subject: S, options: UITextInputBindingOption) -> AnyCancellable where S.Output == NSAttributedString?, S.Failure == Never {
        makeBindings(for: subject, options: options, keyPath: \.attributedText)
    }
    
    func subscribeAndSendText<S: Subject>(to subject: S, options: UITextInputBindingOption) -> AnyCancellable where S.Output == String, S.Failure == Never {
        return makeBindings(for: subject, options: options, keyPath: \.text)
    }
    
    func subscribeAndSendAttributedText<S: Subject>(to subject: S, options: UITextInputBindingOption) -> AnyCancellable where S.Output == NSAttributedString, S.Failure == Never {
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
