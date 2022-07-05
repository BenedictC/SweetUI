import Foundation
import UIKit


// MARK: - End editing on return

public extension UITextField {

    func delegateWithReturnAction(next: UIResponder) -> Self {
        let delegate = TextFieldKeyboardDelegate.shared
        let action = TextFieldKeyboardDelegate.Action(handler: { [weak next] in next?.becomeFirstResponder() })
        delegate.setAction(action, for: self)
        self.delegate = delegate
        return self
    }

    func delegateWithReturnAction(_ handler: (() -> Void)? = nil) -> Self {
        let delegate = TextFieldKeyboardDelegate.shared
        let action = TextFieldKeyboardDelegate.Action(handler: handler)
        delegate.setAction(action, for: self)
        self.delegate = delegate
        return self
    }

    func delegateWithReturnAction(_ handler: @escaping ((Self) -> Void)) -> Self {
        let delegate = TextFieldKeyboardDelegate.shared
        let action = TextFieldKeyboardDelegate.Action { [weak self] in
            guard let self = self else {
                return
            }
            handler(self)
        }
        delegate.setAction(action, for: self)
        self.delegate = delegate
        return self
    }
}


public extension UITextField {

    func delegateWithReturnAction<T: ViewIsAvailableProvider>(with provider: T, _ handler: @escaping ((Self, T) -> Void)) -> Self {
        let delegate = TextFieldKeyboardDelegate.shared
        let action = TextFieldKeyboardDelegate.Action { [weak self, weak provider] in
            guard let self = self,
                  let provider = provider else {
                return
            }
            handler(self, provider)
        }
        delegate.setAction(action, for: self)
        self.delegate = delegate
        return self
    }
}


// MARK: - 

private final class TextFieldKeyboardDelegate: NSObject, UITextFieldDelegate {

    class Action {

        let handler: () -> Void

        init?(handler: (() -> Void)?) {
            guard let handler = handler else {
                return nil
            }
            self.handler = handler
        }

        func execute() {
            handler()
        }
    }


    static let shared = TextFieldKeyboardDelegate()

    let actions = NSMapTable<UITextField, Action>.weakToStrongObjects()

    func setAction(_ action: Action?, for textField: UITextField) {
        guard let action = action else {
            actions.removeObject(forKey: textField)
            return
        }
        actions.setObject(action, forKey: textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let action = actions.object(forKey: textField)
        action?.execute()
        return false
    }
}
