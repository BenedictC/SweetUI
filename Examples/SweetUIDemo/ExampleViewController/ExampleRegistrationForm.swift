import Foundation
import Combine


final class ExampleRegistrationForm {

    // MARK: Publishers

    @Published var name: String?
    var isNameValid: AnyPublisher<Bool, Never> { $name.map(Self.isValidName).eraseToAnyPublisher() }

    @Published var email: String?
    var isEmailValid: AnyPublisher<Bool, Never> { $email.map(Self.isValidEmail).eraseToAnyPublisher() }

    @Published var password: String?
    var isPasswordValid: AnyPublisher<Bool, Never> { $password.map(Self.isValidPassword).eraseToAnyPublisher() }

    var isValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isNameValid, isEmailValid, isPasswordValid)
            .map { $0.0 && $0.1 && $0.2 }
            .eraseToAnyPublisher()
    }

    func reset() {
        name = nil
        email = nil
        password = nil
    }
}


// MARK: - Validation

extension ExampleRegistrationForm {

    private static let linkDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)

    
    static func isValidName(_ optionalName: String?) -> Bool {
        let name = optionalName ?? ""
        let isEmpty = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return !isEmpty
    }

    static func isValidEmail(_ optionalEmail: String?) -> Bool {
        let email = optionalEmail ?? ""
        let fullRange = NSRange(location: 0, length: email.utf16.count)
        let firstMatch = linkDetector.firstMatch(in: email, options: [], range: fullRange)
        let scheme = firstMatch?.url?.scheme ?? ""
        let isEmail = scheme == "mailto"
        let isCompleteMatch = firstMatch?.range == fullRange
        return isEmail && isCompleteMatch
    }

    static func isValidPassword(_ optionalPassword: String?) -> Bool {
        let password = optionalPassword ?? ""
        return password.count >= 8
        && password.contains(where: { $0.isLetter })
        && password.contains(where: { $0.isNumber })
    }

    static func isValid(_ form: ExampleRegistrationForm) -> Bool {
        return isValidName(form.name)
        && isValidEmail(form.email)
        && isValidPassword(form.password)
    }
}
