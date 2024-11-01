import UIKit
import Combine


// MARK: - Title

@MainActor
public extension SomeView where Self: UIButton {
    
    func title<P: Publisher>(
        _ publisher: P,
        for state: UIControl.State = .normal
    )
    -> Self where P.Output == String, P.Failure == Never {
        publisher.sink { [weak self] title in
            self?.setTitle(title, for: state)            
        }
        .store(in: CancellableStorage.current)
        return self
    }
    
    func title<P: Publisher>(
        _ publisher: P,
        for state: UIControl.State = .normal
    )
    -> Self where P.Output == String?, P.Failure == Never {
        publisher.sink { [weak self] title in
            self?.setTitle(title, for: state)
        }
        .store(in: CancellableStorage.current)
        return self
    }
}


// MARK: - Selected

@MainActor
public extension SomeView where Self: UIButton {
    
    func selected<S: Subject>(
        bindsTo subject: S
    )
    -> Self where S.Output == Bool, S.Failure == Never {
        subscribeAndSendIsSelected(to: subject)
            .store(in: CancellableStorage.current)
        return self
    }
}


// MARK: - Core

private extension UIButton {
    
    func subscribeAndSendIsSelected<S: Subject>(to subject: S) -> AnyCancellable where S.Output == Bool, S.Failure == Never {
        return ButtonIsSelectedToggler.shared.bindIsSelected(of: self, to: subject)
    }
}


// MARK: - ButtonIsSelectedToggler

// This class could be generalised but it would get even more complicated.
private class ButtonIsSelectedToggler: NSObject {
    
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
