import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public enum BindingFactoryMacroError: Error {
    case unknown(String)
}

struct BindingFactoryMacro: ExpressionMacro {
    
    static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        guard
            let macroSyntax = node.as(MacroExpansionExprSyntax.self)
//            let propertyName = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            throw BindingFactoryMacroError.unknown("\(node)")
        }

        var bindingClass = macroSyntax.macroName.trimmed.text
        var valueKeyPath: String?
        var publisherKeyPath: String?
        var captureObject: String?
        for element in macroSyntax.arguments {
            let label = element.label?.trimmed.text ?? ""
            guard label == "toPublishedAt" else { continue }
            (valueKeyPath, publisherKeyPath, captureObject) = try makeKeyPathAndCaptureObject(from: "\(element.expression.trimmed)")
            break
        }
        guard let valueKeyPath, let publisherKeyPath, let captureObject else {
            throw BindingFactoryMacroError.unknown("\(valueKeyPath ?? "<nil>") | \(publisherKeyPath ?? "<nil>") | \(captureObject ?? "<nil>")")
        }
        return ExprSyntax("""
        \(raw: bindingClass)(for: (publisher: \(raw: publisherKeyPath), accessor: \(raw: valueKeyPath)), of: \(raw: captureObject))
        """)
    }

    static func makeKeyPathAndCaptureObject(from expression: String) throws -> (valueKeyPath: String, publisherKeyPath: String, captureObject: String?) {
        let components = expression.components(separatedBy: ".")
        guard let lastComponent = components.last else {
            throw BindingFactoryMacroError.unknown("Invalid express")
        }
        let valueKeyPath = "\\.\(lastComponent)"
        let publisherKeyPath = "\\.$\(lastComponent)"
        let captureObject = components.count == 1 ? "self" : components.dropLast().joined(separator: ".")
        return (valueKeyPath, publisherKeyPath, captureObject)
    }
}
