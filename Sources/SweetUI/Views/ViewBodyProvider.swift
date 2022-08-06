import Foundation
import UIKit


// MARK: - Core

public protocol ViewBodyProvider: _ViewBodyProvider {

    // Required
    associatedtype Body: UIView
    var body: Body { get }

    // Optional from _ViewBodyProvider (and duplicated for clarity)
    typealias Initializer = ViewInitializer<Self>
    static var initializer: Initializer { get }
    var bodyContainer: UIView { get }
}


public protocol _ViewBodyProvider: UIView { // Core functionality avoiding associated types

    var _body: UIView { get }
    var bodyContainer: UIView { get }

    static func initializeInstance(of view: _ViewBodyProvider)
    static func initializeBody(of view: _ViewBodyProvider)
}


// MARK: - Supporting type

public struct ViewInitializer<T: UIView> {

    let handler: (T) -> Void

    public init<R>(_ handler: @escaping (T) -> R) {
        self.handler = { _ = handler($0) }
    }
}


// MARK: - Default implementation

public extension ViewBodyProvider {

    static var initializer: Initializer { Initializer { _ in } }

    var _body: UIView { body }

    var bodyContainer: UIView { self }

    static func initializeInstance(of view: _ViewBodyProvider) {
        guard let view = view as? Self else {
            preconditionFailure("_initialize(instance:) must only be called with instances of Self")
        }
        _ = initializer.handler(view)
    }

    static func initializeBody(of host: _ViewBodyProvider) {
        let body = host._body
        let container = host.bodyContainer
        container.addAndFill(subview: body, overrideEdgesIgnoringSafeArea: nil)
    }
}


// MARK: - Convenience

extension _ViewBodyProvider {

    func initializeBodyHosting() {
        Self.initializeInstance(of: self)
        Self.initializeBody(of: self)
    }
}
