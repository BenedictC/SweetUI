import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public enum ExposedBindingPeerMacroError: Error {
    case incorrectNodeType(String)
    case propertyNotABinding(String)
    case unknown(String)
    case unableToDetermineTypeOfProperty
}


public struct ExposedBindingPeerMacro: PeerMacro {

    public static func expansion(
        of exposedAttribute: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard 
            let variableDecl = declaration.as(VariableDeclSyntax.self),
            let patternBinding = variableDecl.bindings.children(viewMode: .fixedUp).first?.as(PatternBindingSyntax.self),
            let propertyName = patternBinding.pattern.as(IdentifierPatternSyntax.self)?.identifier
        else {
            throw ExposedBindingPeerMacroError.unknown("😭")
        }
        try assertPropertyIsBinding(variableDeclarationSyntax: variableDecl)

        // Get arguments
        var asOneWay = false
        var explicitName: String?
        var accessLevel = ""
        if let arguments = exposedAttribute.arguments {
            if case .argumentList(let labeledExprListSyntax) = arguments {
                for element in labeledExprListSyntax {
                    switch element.label?.trimmed.text {
                    case "name":
                        // TODO: Check the name is valid
                        explicitName = String("\(element.expression)".dropFirst().dropLast())

                    case "accessLevel":
                        accessLevel = "\(element.expression)".trimmingCharacters(in: .letters.inverted)

                    case "asOneWay":
                        asOneWay = Bool("\(element.expression)") ?? false
                    default:
                        continue
                    }
                }
            }
        }
        accessLevel = accessLevel == "default" ? "" : accessLevel
        let sourceName = propertyName.text
        let destinationName = explicitName ?? sourceName + "Binding"

        // Get value type
        if let typeSyntax = patternBinding.typeAnnotation?.type.trimmed {
            let type = "\(typeSyntax)"
            return makeComputedPropertyDeclaration(sourceName: sourceName, destinationName: destinationName, type: type, asOneWay: asOneWay, accessLevel: accessLevel)
        }
        if let initClauseSyntax = patternBinding.initializer,
           let type = type(forExpr: initClauseSyntax.value) {
            return makeComputedPropertyDeclaration(sourceName: sourceName, destinationName: destinationName, type: type, asOneWay: asOneWay, accessLevel: accessLevel)
        }
        return try makeStoredBindingPropertyDeclaration(sourceName: propertyName.text, destinationName: destinationName, asOneWay: asOneWay, accessLevel: accessLevel, variableDeclarationSyntax: variableDecl)
    }

    static func assertPropertyIsBinding(variableDeclarationSyntax: VariableDeclSyntax) throws {
        let attributeNames = variableDeclarationSyntax.attributes.children(viewMode: .fixedUp).compactMap {
            $0.as(AttributeSyntax.self).flatMap { "\($0.attributeName.trimmed)" }
        }
        guard attributeNames.contains("Binding") else {
            throw ExposedBindingPeerMacroError.propertyNotABinding("@Exposed can only be applied to properties with the @Binding attribute.")
        }
    }

    static func type(forExpr exprSyntax: ExprSyntax) -> String? {
        if exprSyntax.is(IntegerLiteralExprSyntax.self) { return "Int" }
        if exprSyntax.is(StringLiteralExprSyntax.self) { return  "String" }
        if exprSyntax.is(FloatLiteralExprSyntax.self) { return "Double" }
        if exprSyntax.is(BooleanLiteralExprSyntax.self) { return "Bool" }

        if let arrayExpr = exprSyntax.as(ArrayExprSyntax.self) {
            return type(ForArrayLiteral: arrayExpr)
        }
        if let dictExpr = exprSyntax.as(DictionaryExprSyntax.self) {
            return type(ForDictionaryLiteral: dictExpr)
        }
        return nil
    }

    static func type(ForArrayLiteral arrayExpr: ArrayExprSyntax) -> String? {
        let types = arrayExpr.elements.map { type(forExpr: $0.expression) }
        guard types.allSatisfy({ $0 != nil }), let first = types.first else { return nil }

        return types.reduce(first) { current, next in
            if current == "Any" { return current }
            if current == next { return current }
            if current == "Int" && next == "Double" { return next }
            return "Any"
        }
    }

    static func type(ForDictionaryLiteral dictExpr: DictionaryExprSyntax) -> String? {
        nil
    }


    static func makeComputedPropertyDeclaration(sourceName: String, destinationName: String, type: String, asOneWay: Bool, accessLevel: String) -> [DeclSyntax] {
        let bindingClassName = asOneWay ? "OneWayBinding" : "Binding"
        return [
            DeclSyntax("\(raw: accessLevel) var \(raw: destinationName): \(raw: bindingClassName)<\(raw: type)> { $\(raw: sourceName) }")
        ]
    }

    static func makeStoredBindingPropertyDeclaration(sourceName: String, destinationName: String, asOneWay: Bool, accessLevel: String, variableDeclarationSyntax: VariableDeclSyntax) throws -> [DeclSyntax] {
        throw ExposedBindingPeerMacroError.unableToDetermineTypeOfProperty
        // The compile can't handle `private(set)`. `private` works but is of no use.
//        let name = sourcePropertyName + "Binding"
//        let code =
//        return [
//            DeclSyntax(
//            """
//            private lazy var \(name): Any = $\(sourcePropertyName)
//            {
//                didSet {
//                    \(name) = oldValue
//                    print("Attempted to set value of @Exposed @Binding '\(name)'. New value ignored.")
//                }
//            }
//            """
//            )
//        ]
    }
}
