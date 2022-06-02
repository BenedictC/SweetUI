import Foundation
import UIKit


// MARK: - Core

public protocol ViewBodyProvider: _ViewBodyProvider {

    associatedtype Body: UIView

    // Required
    var body: Body { get }

    // Optional from _ViewBodyProvider (and duplicated for clarity)
    var bodyContainer: BodyContainer { get }
}

public protocol _ViewBodyProvider: UIView { // Core functionality avoiding associated types

    var _body: UIView { get }
    var bodyContainer: BodyContainer { get }
}


// MARK: - Supporting Types

public final class BodyContainer {

    public private(set) weak var view: UIView!

    public init(_ view: UIView) {
        self.view = view
    }

    public init(_ viewBuilder: () -> UIView) {
        self.view = viewBuilder()
    }
}


// MARK: - Default implementation

public extension ViewBodyProvider {

    var _body: UIView { body }
}


public extension _ViewBodyProvider {

    var bodyContainer: BodyContainer { BodyContainer(self) }

    func initializeBody() {
        Self.initializeBody(of: self)
    }
}


// MARK: - Initialization

private extension _ViewBodyProvider {

    static func initializeBody(of host: _ViewBodyProvider) {
        let body = host._body
        guard let container = host.bodyContainer.view else {
            preconditionFailure()
        }
        container.addAndFill(subview: body, overrideEdgesIgnoringSafeArea: nil)
    }
}
