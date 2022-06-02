import UIKit
import Combine


// MARK: - Core

public extension UIButton {

    func subscribeAndSendIsSelected(to subject: CurrentValueSubject<Bool, Never>) -> AnyCancellable {
        return ButtonIsSelectedToggler.shared.bindIsSelected(of: self, to: subject)
    }
}


// MARK: - ViewConnectionProvider continuous

public extension SomeView where Self: UIButton {

    func bindIsSelected<T: ViewConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, _ keyPath: KeyPath<T, CurrentValueSubject<Bool, Never>>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { button, source in
            button.subscribeAndSendIsSelected(to: source[keyPath: keyPath])
        }
    }

    func bindIsSelected<T: ViewConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, builder: @escaping (Self, T) -> CurrentValueSubject<Bool, Never>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { button, source in
            button.subscribeAndSendIsSelected(to: builder(button, source))
        }
    }
}


// MARK: - ViewModelConnectionProvider continuous

public extension SomeView where Self: UIButton {

    func bindIsSelected<T: ViewModelConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, _ keyPath: KeyPath<T.ViewModel, CurrentValueSubject<Bool, Never>>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { button, _, viewModel in
            button.subscribeAndSendIsSelected(to: viewModel[keyPath: keyPath])
        }
    }

    func bindIsSelected<T: ViewModelConnectionProvider>(connectionIdentifier: AnyHashable = UUID(), to source: T, builder: @escaping (Self, T, T.ViewModel) -> CurrentValueSubject<Bool, Never>) -> Self {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { button, source, viewModel in
            button.subscribeAndSendIsSelected(to: builder(button, source, viewModel))
        }
    }
}


// MARK: - ButtonIsSelectedToggler

// This class could be generalised but it would get even more complicated.
class ButtonIsSelectedToggler: NSObject {

    static let shared = ButtonIsSelectedToggler()

    private var subjectsByButton = NSMapTable<UIButton, NSMutableSet>.weakToStrongObjects()

    private func subjects(for button: UIButton) -> NSMutableSet {
        if let existing = subjectsByButton.object(forKey: button) {
            return existing
        }
        let subjects = NSMutableSet()
        subjectsByButton.setObject(subjects, forKey: button)
        return subjects
    }

    func bindIsSelected(of button: UIButton, to subject: CurrentValueSubject<Bool, Never>) -> AnyCancellable {
        // Store the subject
        subjects(for: button).add(subject)

        // Add the target
        button.addTarget(self, action: #selector(toggle(_:)), for: .primaryActionTriggered)
        let sendCancellable = AnyCancellable {
            button.removeTarget(self, action: #selector(self.toggle(_:)), for: .primaryActionTriggered)
        }
        let receiveCancellable = subject.sink { button.isSelected = $0 }

        return AnyCancellable {
            [sendCancellable, receiveCancellable].forEach { $0.cancel() }
        }
    }


    @objc
    private func toggle(_ sender: Any?) {
        guard let button = sender as? UIButton else {
            return
        }
        button.isSelected.toggle()

        let newValue = button.isSelected
        subjects(for: button)
            .compactMap { $0 as? CurrentValueSubject<Bool, Never> }
            .forEach { $0.send(newValue) }
    }
}
