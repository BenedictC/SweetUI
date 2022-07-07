import UIKit
import SweetUI
import Combine


// MARK: - ViewModel

protocol ExampleViewModel: AnyObject {

    typealias ValidationKeyPath = KeyPath<ExampleViewModel, ViewState<Bool>>

    var nameBinding: ViewBinding<String?> { get }
    var isNameValidState: ViewState<Bool> { get }

    var emailBinding: ViewBinding<String?> { get }
    var isEmailValidState: ViewState<Bool> { get }

    var passwordBinding: ViewBinding<String?> { get }
    var isPasswordValidState: ViewState<Bool> { get }

    var statusState: ViewState<ExampleView.Status> { get }

    func didEndEditing(for validationKeyPath: ValidationKeyPath)
    func submit()
}

private extension ExampleViewModel {

    var isReadyToSubmit: ViewState<Bool> {
        statusState
            .map { $0 == .ready }
            .eraseToAnyPublisher()
    }

    var isWaiting: ViewState<Bool> {
        statusState
            .map { $0 == .waiting }
            .eraseToAnyPublisher()
    }

    var nameLabelAlpha: ViewState<CGFloat> { isNameValidState.map { $0 ? CGFloat(0) : CGFloat(1) }.eraseToAnyPublisher() }
    var emailLabelAlpha: ViewState<CGFloat> { isEmailValidState.map { $0 ? CGFloat(0) : CGFloat(1) }.eraseToAnyPublisher() }
    var passwordLabelAlpha: ViewState<CGFloat> { isPasswordValidState.map { $0 ? CGFloat(0) : CGFloat(1) }.eraseToAnyPublisher() }
}


// MARK: - View

class ExampleView: View<ExampleViewModel> {

    // MARK: Types

    enum Status {
        case invalid, ready, waiting
    }


    // MARK: Properties

    // Content

    private lazy var nameTextField = makeTextField(placeholder: "Name")
        .bindText(to: self) { $1.viewModel.nameBinding }
        .delegateWithReturnAction(next: emailTextField)
        .on(.editingDidEnd, with: self) { $1.viewModel.didEndEditing(for: \.isNameValidState) }

    private lazy var nameValidationErrorLabel = makeLabel(text: "Name must be at least 1 character long")
        .assign(\.alpha, from: self, \.viewModel.nameLabelAlpha)

    private lazy var emailTextField = makeTextField(placeholder: "Email")
        .keyboardType(.emailAddress)
        .autocapitalizationType(.none)
        .bindText(to: self) { $1.viewModel.emailBinding }
        .delegateWithReturnAction(next: passwordTextField)
        .on(.editingDidEnd, with: self) { $1.viewModel.didEndEditing(for: \.isEmailValidState) }

    private lazy var emailValidationErrorLabel = makeLabel(text: "Email must be a valid email address")
        .assign(\.alpha, from: self, \.viewModel.emailLabelAlpha)

    private lazy var passwordTextField = makeTextField(placeholder: "Password")
        .isSecureTextEntry(true)
        .bindText(to: self) { $1.viewModel.passwordBinding }
        .on(.editingDidEnd, with: self) { $1.viewModel.didEndEditing(for: \.isPasswordValidState) }
        .delegateWithReturnAction { [weak self] in self?.submit() }

    private lazy var passwordValidationErrorLabel = makeLabel(text: "Password must be at least 8 characters long and contain a letter and a number")
        .assign(\.alpha, from: self, \.viewModel.passwordLabelAlpha)

    private lazy var submitButton = UIButton(type: .system)
        .title("Submit", for: .normal)
        .assign(\.isEnabled, from: self) { $1.viewModel.isReadyToSubmit }
        .on(.primaryActionTriggered, with: self) { $1.submit() }

    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
        .backgroundColor(.secondarySystemFill.withAlphaComponent(0.5))
        .animate(true)
        .assign(\.isActive, from: self) { $1.viewModel.isWaiting }


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
