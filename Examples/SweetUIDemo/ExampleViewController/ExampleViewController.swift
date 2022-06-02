import UIKit
import SweetUI
import Combine


class ExampleViewController: ContentViewController {

    // MARK: - Instance life cycle

    override init() {
        super.init()
        title = "Example"
    }

    
    // MARK: - Properties

    lazy var rootView = ExampleView(viewModel: self)
        .backgroundColor(.systemBackground)
    private let form = ExampleRegistrationForm()
    private let isSubmitInProgress = ViewBinding(false)

    private let validationKeyPathsSubject = ViewBinding(Set<ExampleViewModel.ValidationKeyPath>())


    // MARK: - View life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rootView.beginEditing()
    }
}


extension ExampleViewController: ExampleViewModel {

    var nameSubject: ViewBinding<String?> { form.nameSubject }
    var isNameValid: ViewState<Bool> { makeValidationPublisher(for: form.isNameValid, keyPath: \.isNameValid) }
    var emailSubject: ViewBinding<String?> { form.emailSubject }
    var isEmailValid: ViewState<Bool> { makeValidationPublisher(for: form.isEmailValid, keyPath: \.isEmailValid) }
    var passwordSubject: ViewBinding<String?> { form.passwordSubject }
    var isPasswordValid: ViewState<Bool> { makeValidationPublisher(for: form.isPasswordValid, keyPath: \.isPasswordValid) }

    var isReadyToSubmit: ViewState<Bool> { form.isValid }

    var status: ViewState<ExampleView.Status> {
        Publishers.CombineLatest(isReadyToSubmit, isSubmitInProgress).map {
            let (isReady, isInProgress) = $0
            if isInProgress { return ExampleView.Status.waiting }
            if isReady { return ExampleView.Status.ready }
            return ExampleView.Status.invalid
        }
        .eraseToAnyPublisher()
    }

    func didEndEditing(for validationKeyPath: ValidationKeyPath) {
        validationKeyPathsSubject.send { $0.insert(validationKeyPath) }
    }

    func submit() {
        guard ExampleRegistrationForm.isValid(form) else {
            return
        }
        pretendToSubmitForm()
    }
}


private extension ExampleViewController {

    func makeValidationPublisher(for validationPublisher: ViewState<Bool>, keyPath: ExampleViewModel.ValidationKeyPath) -> ViewState<Bool> {
        validationPublisher.combineLatest(validationKeyPathsSubject).map {
            let (isValid, keyPathsToValidate) = $0
            let shouldSkipValidation = !keyPathsToValidate.contains(keyPath)
            return shouldSkipValidation ? true : isValid
        }
        .eraseToAnyPublisher()
    }

    func pretendToSubmitForm() {
        isSubmitInProgress.send(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.isSubmitInProgress.send(false)

            let alertVC = UIAlertController(title: "Success!", message: "Form submitted", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.resetState() })
            self.present(alertVC, animated: true)
        }
    }

    func resetState() {
        nameSubject.send(nil)
        emailSubject.send(nil)
        passwordSubject.send(nil)
        validationKeyPathsSubject.send { $0.removeAll() }
        rootView.beginEditing()
    }
}
