import UIKit
import SweetUI
import Combine


class FormViewController: ViewController {

    // MARK: Types

    enum Status {
        case invalid, ready, waiting
    }

    typealias ValidationKeyPath = KeyPath<RegistrationForm, ViewState<Bool>>


    // MARK: Instance life cycle

    override init() {
        super.init()
        title = "Form Example"
    }

    
    // MARK: Properties

    private let form = RegistrationForm()

    @Published private var isSubmitInProgress = false
    @Published private var validationKeyPaths = Set<ValidationKeyPath>()
    private lazy var status = Publishers
        .CombineLatest($isSubmitInProgress, form.isValid)
        .map { pair -> Status in
            let (isSubmitInProgress, isValid) = pair
            if isSubmitInProgress { return .waiting }
            return isValid ? .ready : .invalid
        }
    private lazy var isReadyToSubmit = status.map { $0 == .ready }
    private lazy var isWaiting = status.map { $0 == .waiting }
    private lazy var nameValidationErrorLabelAlpha = makeValidationPublisher(for: \.isNameValid)
    private lazy var emailValidationErrorLabelAlpha = makeValidationPublisher(for: \.isEmailValid)
    private lazy var passwordValidationErrorLabelAlpha = makeValidationPublisher(for: \.isPasswordValid)


    // Content views

    private lazy var nameTextField = makeTextField(placeholder: "Name")
            .bindText(to: PublishedSubject(form, read: \.$name, write: \.name))
            .delegateWithReturnAction(next: emailTextField)
            .on(.editingDidEnd) { [weak self] _ in self?.didEndEditing(for: \.isNameValid) }

    private lazy var nameValidationErrorLabel = makeValidationErrorLabel(text: "Name must be at least 1 character long")
            .assign(to: \.alpha, from: nameValidationErrorLabelAlpha)

    private lazy var emailTextField = makeTextField(placeholder: "Email")
            .keyboardType(.emailAddress)
            .autocapitalizationType(.none)
            .bindText(to: PublishedSubject(form, read: \.$email, write: \.email))
            .delegateWithReturnAction(next: passwordTextField)
            .on(.editingDidEnd) { [weak self] _ in self?.didEndEditing(for: \.isEmailValid) }

    private lazy var emailValidationErrorLabel = makeValidationErrorLabel(text: "Email must be a valid email address")
            .assign(to: \.alpha, from: emailValidationErrorLabelAlpha)

    private lazy var passwordTextField = makeTextField(placeholder: "Password")
            .isSecureTextEntry(true)
            .bindText(to: PublishedSubject(form, read: \.$password, write: \.password))
            .on(.editingDidEnd) { [weak self] _ in self?.didEndEditing(for: \.isPasswordValid) }
            .delegateWithReturnAction { [weak self] in self?.submit() }

    private lazy var passwordValidationErrorLabel = makeValidationErrorLabel(text: "Password must be at least 8 characters long and contain a letter and a number")
            .assign(to: \.alpha, from: passwordValidationErrorLabelAlpha)

    private lazy var submitButton = UIButton(type: .system)
            .title("Submit", for: .normal)
            .assign(to: \.isEnabled, from: isReadyToSubmit)
            .on(.primaryActionTriggered) { [weak self] _ in self?.submit() }

    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
            .backgroundColor(.secondarySystemFill.withAlphaComponent(0.5))
            .animate(true)
            .assign(to: \.isActive, from: isWaiting)


    // Layout views

    lazy var rootView = ScrollingContentLayout(
        configuration: .init(paddingColor: .blue)
    ) {
        ZStack(alignment: .fill) {
            VStack(spacing: 10) {
                VStack {
                    nameTextField
                        .frame(height: 44)
                    nameValidationErrorLabel
                }
                VStack {
                    emailTextField
                        .frame(height: 44)
                    emailValidationErrorLabel
                }
                VStack {
                    passwordTextField
                        .frame(height: 44)
                    passwordValidationErrorLabel
                }
                submitButton
            }
            .contentHugs(in: .vertical, at: .defaultLow)
            activityIndicator
                .contentHugs(in: .vertical, at: .defaultLow)
        }
    }
}


// MARK: - View life cycle

extension FormViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        nameTextField.becomeFirstResponder()
    }
}


// MARK: - Actions

private extension FormViewController {

    func didEndEditing(for validationKeyPath: ValidationKeyPath) {
        validationKeyPaths.insert(validationKeyPath)
    }

    func resetState() {
        form.reset()
        nameTextField.becomeFirstResponder()
        // Clearing validationKeyPaths has to be done after setting first responder because when the
        // resigning textField loses focus it is added to validationKeyPaths which would be incorrect
        validationKeyPaths.removeAll()
    }

    func submit() {
        guard RegistrationForm.isValid(form) else {
            return
        }
        rootView.resignFirstResponder()
        isSubmitInProgress = true
        let alertVC = AlertController<Void>(title: "Success!", message: "Form submitted", preferredStyle: .alert,components: [
            .standardAction("OK", value: ())
        ])
        Task {
            try? await Task.sleep(for: .seconds(2))
            self.isSubmitInProgress = false
            try? await self.present(alertVC, animated: true)
            resetState()
        }
    }
}


// MARK: - Factories

private extension FormViewController {

    func makeValidationPublisher(for validationKeyPath: ValidationKeyPath) -> AnyPublisher<CGFloat, Never> {
        let validationPublisher = form[keyPath: validationKeyPath]
        return Publishers.CombineLatest(validationPublisher, $validationKeyPaths)
            .map { pair in
                let (isValid, validationKeyPaths) = pair
                let shouldShowValidation = validationKeyPaths.contains(validationKeyPath)
                return shouldShowValidation && !isValid ? CGFloat(1) : CGFloat(0)
            }
            .eraseToAnyPublisher()
    }

    func makeTextField(placeholder: String) -> UITextField {
        UITextField()
            .borderStyle(.roundedRect)
            .placeholder(placeholder)
    }

    private func makeValidationErrorLabel(text: String) -> UILabel {
        UILabel()
            .text(text)
            .font(.preferredFont(forTextStyle: .caption1))
            .numberOfLines(0)
            .textColor(.systemRed)
    }
}
