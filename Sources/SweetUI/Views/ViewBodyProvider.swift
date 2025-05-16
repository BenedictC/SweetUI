import Foundation
import UIKit


// MARK: - Core

public protocol ViewBodyProvider: _ViewBodyProvider {

    // Required
    associatedtype Body: UIView
    var body: Body { get }

    // Optional from _ViewBodyProvider (and duplicated for clarity)
    func awake()
    var bodyContainer: UIView { get }
    static func arrangeBody(_ body: UIView, in container: UIView)
}


public protocol _ViewBodyProvider: UIView, CancellableStorageProvider { // Core functionality avoiding associated types

    func awake()
    var bodyContainer: UIView { get }
    static func arrangeBody(_ body: UIView, in container: UIView)

    
    var _body: UIView { get } // Implement in a ViewBodyProvider extension. Should not override
    static func _initializeBody(of view: _ViewBodyProvider)
}


// MARK: - Default implementation

public extension ViewBodyProvider {

    var bodyContainer: UIView { self }

    var _body: UIView { body }

    static func _initializeBody(of anyHost: _ViewBodyProvider) {
        guard let host = anyHost as? Self else {
            fatalError()
        }
        let body = host._body
        let container = host.bodyContainer
        let isSelfHosted = body == container
        if isSelfHosted {
            return
        }
        Self.arrangeBody(body, in: container)
    }
}


// MARK: - Convenience

public extension _ViewBodyProvider {

    func initializeBodyHosting() {
        if _body.superview == nil {
            detectPotentialRetainCycle(of: self) {
                Self._initializeBody(of: self)
            }
        }
    }

    func awake() {

    }
}
