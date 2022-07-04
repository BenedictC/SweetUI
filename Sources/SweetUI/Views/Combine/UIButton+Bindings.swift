import UIKit
import Combine


// MARK: - Core

public extension UIButton {

    func subscribeAndSendIsSelected<S: Subject>(to subject: S) -> AnyCancellable where S.Output == Bool, S.Failure == Never {
        return ButtonIsSelectedToggler.shared.bindIsSelected(of: self, to: subject)
    }
}


// MARK: - ViewConnectionProvider continuous

public extension SomeView where Self: UIButton {

    func bindIsSelected<P: ViewConnectionProvider, S: Subject>(connectionIdentifier: AnyHashable = UUID(), to provider: P, _ keyPath: KeyPath<P, S>) -> Self where S.Output == Bool, S.Failure == Never {
        subscribeToConnection(of: provider, connectionIdentifier: connectionIdentifier) { button, provider in
            button.subscribeAndSendIsSelected(to: provider[keyPath: keyPath])
        }
    }

    func bindIsSelected<P: ViewConnectionProvider, S: Subject>(connectionIdentifier: AnyHashable = UUID(), to provider: P, builder: @escaping (Self, P) -> S) -> Self where S.Output == Bool, S.Failure == Never {
        subscribeToConnection(of: provider, connectionIdentifier: connectionIdentifier) { button, provider in
            button.subscribeAndSendIsSelected(to: builder(button, provider))
        }
    }
}


// MARK: - ViewModelConnectionProvider continuous

public extension SomeView where Self: UIButton {

    func bindIsSelected<P: ViewModelConnectionProvider, S: Subject>(connectionIdentifier: AnyHashable = UUID(), to provider: P, _ keyPath: KeyPath<P.ViewModel, S>) -> Self where S.Output == Bool, S.Failure == Never {
        subscribeToConnection(of: provider, connectionIdentifier: connectionIdentifier) { button, _, viewModel in
            button.subscribeAndSendIsSelected(to: viewModel[keyPath: keyPath])
        }
    }

    func bindIsSelected<P: ViewModelConnectionProvider, S: Subject>(connectionIdentifier: AnyHashable = UUID(), to provider: P, builder: @escaping (Self, P, P.ViewModel) -> S) -> Self where S.Output == Bool, S.Failure == Never {
        subscribeToConnection(of: provider, connectionIdentifier: connectionIdentifier) { button, provider, viewModel in
            button.subscribeAndSendIsSelected(to: builder(button, provider, viewModel))
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

    func bindIsSelected<S: Subject>(of button: UIButton, to subject: S) -> AnyCancellable where S.Output == Bool, S.Failure == Never {
        let anySubject = subject.eraseToAnySubject()
        // Store the subject
        subjects(for: button).add(anySubject)

        // Add the target
        button.addTarget(self, action: #selector(toggle(_:)), for: .primaryActionTriggered)
        let sendCancellable = AnyCancellable {
            button.removeTarget(self, action: #selector(self.toggle(_:)), for: .primaryActionTriggered)
        }
        let receiveCancellable = anySubject.sink { button.isSelected = $0 }

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
            .compactMap { $0 as? AnySubject<Bool, Never> }
            .forEach { $0.send(newValue) }
    }
}
