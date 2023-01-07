import UIKit
import Combine


// MARK: - CancellablesStorageProvider

public extension SomeView where Self: UISwitch {

    func bindIsOn<S: Subject>(
        to subject: S,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store)
    -> Self where S.Output == Bool, S.Failure == Never {
        let cancellable = subscribeAndSendIsOn(to: subject)
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


// MARK: - Core

private extension UISwitch {

    func subscribeAndSendIsOn<S: Subject>(to subject: S) -> AnyCancellable where S.Output == Bool, S.Failure == Never {
        return SwitchIsOnToggler.shared.bindIsOn(of: self, to: subject)
    }
}


// MARK: - ButtonIsSelectedToggler

// This class could be generalised but it would get even more complicated.
private class SwitchIsOnToggler: NSObject {

    static let shared = SwitchIsOnToggler()

    private var subjectsByButton = NSMapTable<UISwitch, NSMutableSet>.weakToStrongObjects()

    private func subjects(for button: UISwitch) -> NSMutableSet {
        if let existing = subjectsByButton.object(forKey: button) {
            return existing
        }
        let subjects = NSMutableSet()
        subjectsByButton.setObject(subjects, forKey: button)
        return subjects
    }

    func bindIsOn<S: Subject>(of button: UISwitch, to subject: S) -> AnyCancellable where S.Output == Bool, S.Failure == Never {
        let anySubject = subject.eraseToAnySubject()
        // Store the subject
        subjects(for: button).add(anySubject)

        // Add the target
        button.addTarget(self, action: #selector(toggle(_:)), for: .primaryActionTriggered)
        let sendCancellable = AnyCancellable {
            button.removeTarget(self, action: #selector(self.toggle(_:)), for: .primaryActionTriggered)
        }
        let receiveCancellable = anySubject.sink {
            if button.isOn != $0 {
                button.isOn = $0
            }
        }

        return AnyCancellable {
            [sendCancellable, receiveCancellable].forEach { $0.cancel() }
        }
    }

    @objc
    private func toggle(_ sender: Any?) {
        guard let button = sender as? UISwitch else {
            return
        }

        let newValue = button.isOn
        subjects(for: button)
            .compactMap { $0 as? AnySubject<Bool, Never> }
            .forEach { $0.send(newValue) }
    }
}
