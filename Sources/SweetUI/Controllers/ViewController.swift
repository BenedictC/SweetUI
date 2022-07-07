import Foundation
import UIKit


// MARK: - ViewController

public typealias ViewController = _ViewController & ViewControllerRequirements


// MARK: - Associated Types

public protocol ViewControllerRequirements: _ViewControllerRequirements {
    associatedtype View: UIView

    var rootView: View { get }
}


public protocol _ViewControllerRequirements: _ViewController {
    var _rootView: UIView { get }
}


// MARK: - Implementation

public extension ViewControllerRequirements {
    var _rootView: UIView { rootView }
}


open class _ViewController: UIViewController, _ViewIsAvailableProviderImplementation, CollectCancellablesProvider, _TraitCollectionDidChangeProviderImplementation {

    // MARK: Properties

    let viewIsAvailableProviderStorage = ViewIsAvailableProviderStorage()
    public let collectCancellablesProviderStorage = CollectCancellablesProviderStorage()
    let traitCollectionDidChangeProviderStorage = TraitCollectionDidChangeProviderStorage()
    

    // MARK: Instance life cycle

    public init() {
        super.init(nibName: nil, bundle: nil)
    }    

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, deprecated, message: "Use viewDidLoad to configure the view.")
    override public func loadView() {
        guard let owner = self as? _ViewControllerRequirements else {
            preconditionFailure("_ViewController must conform to _ViewControllerRequirements")
        }
        let view = owner._rootView
        self.view = view
    }


    // MARK: View life cycle

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewIsAvailableHandlers(isAvailable: true)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateViewIsAvailableHandlers(isAvailable: false)
    }

    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        let current = self.traitCollection
        invokeTraitCollectionDidChangeHandlers(previous: previous, current: current)
    }
}
