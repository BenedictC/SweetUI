import UIKit
import SweetUI
import Combine


class FormViewController: ContentViewController {

    // MARK: - Instance life cycle

    override init() {
        super.init()
        title = "Example"
    }

    
    // MARK: - Properties

    lazy var rootView = FormView(viewModel: self)
        .backgroundColor(.systemBackground)
    private let form = RegistrationForm()
    @Published private var isSubmitInProgress = false
    @Published private var validationKeyPaths = Set<FormViewModel.ValidationKeyPath>()


    // MARK: - View life cycle

    deinit {
        print("Bye from \(Self.self)")
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rootView.beginEditing()
    }
}


extension FormViewController: FormViewModel {
    var nameBinding: ViewBinding<String?> { ViewBinding(for: form, \.name, publisher: form.$name) }
    var isNameValidState: ViewState<Bool> { makeValidationPublisher(for: form.isNameValid, keyPath: \.isNameValidState) }
    var emailBinding: ViewBinding<String?> { ViewBinding(for: form, \.email, publisher: form.$email) }
    var isEmailValidState: ViewState<Bool> { makeValidationPublisher(for: form.isEmailValid, keyPath: \.isEmailValidState) }
    var passwordBinding: ViewBinding<String?> { ViewBinding(for: form, \.password, publisher: form.$password) }
    var isPasswordValidState: ViewState<Bool> { makeValidationPublisher(for: form.isPasswordValid, keyPath: \.isPasswordValidState) }

    var isReadyToSubmit: ViewState<Bool> { form.isValid }

    var statusState: ViewState<FormView.Status> {
        Publishers.CombineLatest(isReadyToSubmit, $isSubmitInProgress).map {
            let (isReady, isInProgress) = $0
            if isInProgress { return FormView.Status.waiting }
            if isReady { return FormView.Status.ready }
            return FormView.Status.invalid
        }
        .eraseToAnyPublisher()
    }

    func didEndEditing(for validationKeyPath: ValidationKeyPath) {
        validationKeyPaths.insert(validationKeyPath)
    }

    func submit() {
        guard RegistrationForm.isValid(form) else {
            return
        }
        pretendToSubmitForm()
    }
}


private extension FormViewController {

    func makeValidationPublisher(for validationPublisher: ViewState<Bool>, keyPath: FormViewModel.ValidationKeyPath) -> ViewState<Bool> {
        validationPublisher.combineLatest($validationKeyPaths).map {
            let (isValid, keyPathsToValidate) = $0
            let shouldSkipValidation = !keyPathsToValidate.contains(keyPath)
            return shouldSkipValidation ? true : isValid
        }
        .eraseToAnyPublisher()
    }

    func pretendToSubmitForm() {
        isSubmitInProgress = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.isSubmitInProgress = false

            let alertVC = UIAlertController(title: "Success!", message: "Form submitted", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default) { _ in self.resetState() })
            self.present(alertVC, animated: true)
        }
    }

    func resetState() {
        form.reset()
        validationKeyPaths.removeAll()
        rootView.beginEditing()
    }
}
