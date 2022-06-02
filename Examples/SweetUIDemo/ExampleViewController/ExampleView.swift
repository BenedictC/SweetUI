import UIKit
import SweetUI
import Combine


// MARK: - ViewModel

protocol ExampleViewModel: AnyObject {

    typealias ValidationKeyPath = KeyPath<ExampleViewModel, ViewState<Bool>>

    var nameSubject: ViewBinding<String?> { get }
    var isNameValid: ViewState<Bool> { get }

    var emailSubject: ViewBinding<String?> { get }
    var isEmailValid: ViewState<Bool> { get }

    var passwordSubject: ViewBinding<String?> { get }
    var isPasswordValid: ViewState<Bool> { get }

    var status: AnyPublisher<ExampleView.Status, Never> { get }

    func didEndEditing(for validationKeyPath: ValidationKeyPath)
    func submit()
}

private extension ExampleViewModel {

    var isReadyToSubmit: ViewState<Bool> {
        status
            .map { $0 == .ready }
            .eraseToAnyPublisher()
    }

    var isWaiting: ViewState<Bool> {
        status
            .map { $0 == .waiting }
            .eraseToAnyPublisher()
    }

    var nameLabelAlpha: ViewState<CGFloat> { isNameValid.map { $0 ? CGFloat(0) : CGFloat(1) }.eraseToAnyPublisher() }
    var emailLabelAlpha: ViewState<CGFloat> { isEmailValid.map { $0 ? CGFloat(0) : CGFloat(1) }.eraseToAnyPublisher() }
    var passwordLabelAlpha: ViewState<CGFloat> { isPasswordValid.map { $0 ? CGFloat(0) : CGFloat(1) }.eraseToAnyPublisher() }
}


// MARK: - View

class ExampleView: View {

    // MARK: Types

    typealias ViewModel = ExampleViewModel

    enum Status {
        case invalid, ready, waiting
    }


    // MARK: Properties

    // Content

    private lazy var nameTextField = makeTextField(placeholder: "Name")
        .bindText(to: self) { $2.nameSubject }
        .delegateWithReturnAction(next: emailTextField)
        .on(.editingDidEnd, with: self) { $2.didEndEditing(for: \.isNameValid) }

    private lazy var nameValidationErrorLabel = makeLabel(text: "Name must be at least 1 character long")
        .assign(\.alpha, from: self, \.nameLabelAlpha)

    private lazy var emailTextField = makeTextField(placeholder: "Email")
        .keyboardType(.emailAddress)
        .autocapitalizationType(.none)
        .bindText(to: self) { $2.emailSubject }
        .delegateWithReturnAction(next: passwordTextField)
        .on(.editingDidEnd, with: self) { $2.didEndEditing(for: \.isEmailValid) }

    private lazy var emailValidationErrorLabel = makeLabel(text: "Email must be a valid email address")
        .assign(\.alpha, from: self, \.emailLabelAlpha)

    private lazy var passwordTextField = makeTextField(placeholder: "Password")
        .isSecureTextEntry(true)
        .bindText(to: self) { $2.passwordSubject }
        .on(.editingDidEnd, with: self) { $2.didEndEditing(for: \.isPasswordValid) }
        .delegateWithReturnAction { [weak self] in self?.submit() }

    private lazy var passwordValidationErrorLabel = makeLabel(text: "Password must be at least 8 characters long and contain a letter and a number")
        .assign(\.alpha, from: self, \.passwordLabelAlpha)

    private lazy var submitButton = UIButton(type: .system)
        .title("Submit", for: .normal)
        .assign(\.isEnabled, from: self) { $2.isReadyToSubmit }
        .on(.primaryActionTriggered, with: self) { $1.submit() }

    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
        .backgroundColor(.secondarySystemFill.withAlphaComponent(0.5))
        .animate(true)
        .assign(\.isActive, from: self) { $2.isWaiting }


    // Layout

    lazy var body = ScrollingContentLayout(
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


// MARK: - Actions

extension ExampleView {

    func beginEditing() {
        nameTextField.becomeFirstResponder()
    }

    private func submit() {
        [nameTextField, emailTextField, passwordTextField]
            .forEach { $0.resignFirstResponder() }
        viewModel?.submit()
    }
}


// MARK: - Factories

private extension ExampleView {

    func makeTextField(placeholder: String) -> UITextField {
        UITextField()
            .borderStyle(.roundedRect)
            .placeholder(placeholder)
    }

    private func makeLabel(text: String) -> UILabel {
        UILabel()
            .text(text)
            .font(.preferredFont(forTextStyle: .caption1))
            .numberOfLines(0)
            .textColor(.systemRed)
    }
}
