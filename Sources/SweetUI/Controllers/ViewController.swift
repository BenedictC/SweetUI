import Foundation
import Combine
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
    var barItems: BarItems { get }
}


// MARK: - Implementation

public extension ViewControllerRequirements {
    var _rootView: UIView { rootView }
}


open class _ViewController: UIViewController, _TraitCollectionPublisherProviderImplementation {

    // MARK: Properties

    public private(set) lazy var _traitCollectionPublisherController = TraitCollectionPublisherController(initialTraitCollection: traitCollection)
    public var isEditingPublisher: AnyPublisher<Bool, Never> { isEditingSubject.eraseToAnyPublisher() }
    internal let isEditingSubject = CurrentValueSubject<Bool, Never>(false)


    // MARK: Instance life cycle

    public init() {
        super.init(nibName: nil, bundle: nil)
        guard let owner = self as? _ViewControllerRequirements else {
            preconditionFailure("_ViewController must conform to _ViewControllerRequirements")
        }
        // Initialize a barItems
        let advice = "Check that closures used to make the barItem that reference the view controller do so with weak references."
        _ = detectPotentialRetainCycle(of: self, advice: advice) { owner.barItems }  // Force load barItems
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
        // If the view ignores all safe areas then it can be used as the self.view directly
        let advice = "Check that closures within the view that reference the view controller are weak, e.g. `button.on(.primaryActionTriggered) { [weak self] _ in self?.submit() }`"
        let rootView = detectPotentialRetainCycle(of: self, advice: advice) { owner._rootView }
        let edgesToIgnore = UIView.edgesIgnoringSafeArea(for: rootView)
        let requiresContainer = edgesToIgnore != .all
        if requiresContainer {
            let container = rootView.ignoresSafeArea(edges: edgesToIgnore)
            self.view = container
        } else {
            self.view = rootView
        }

        let shouldSetBackground = self.view.backgroundColor == nil
        if shouldSetBackground {
            self.view.backgroundColor = .systemBackground
        }
    }


    // MARK: View life cycle

    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        _traitCollectionPublisherController.send(previous: previous, current: traitCollection)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.didDisappear()
    }

    open override func setEditing(_ value: Bool, animated: Bool) {
        super.setEditing(value, animated: animated)
        isEditingSubject.send(value)
    }
}
