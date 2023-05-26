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
    var barItems: BarItems { get }
}


// MARK: - Implementation

public extension ViewControllerRequirements {
    var _rootView: UIView { rootView }
}

private var barItemsByViewController = NSMapTable<UIViewController, BarItems>.weakToStrongObjects()

public extension ViewControllerRequirements where Self: UIViewController {

    var barItems: BarItems {
        if let existing = barItemsByViewController.object(forKey: self) {
            return existing
        }
        let new = BarItems(viewController: self)
        barItemsByViewController.setObject(new, forKey: self)
        return new
    }
}


open class _ViewController: UIViewController, _TraitCollectionPublisherProviderImplementation {

    // MARK: Properties

    public private(set) lazy var _traitCollectionPublisherController = TraitCollectionPublisherController(initialTraitCollection: traitCollection)


    // MARK: Instance life cycle

    public init() {
        super.init(nibName: nil, bundle: nil)
        // Initialize a lazy barsController
        guard let owner = self as? _ViewControllerRequirements else {
            preconditionFailure("_ViewController must conform to _ViewControllerRequirements")
        }
        _ = owner.barItems
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
        let rootView = owner._rootView
        let hasExplicitSafeAreas = rootView is EdgesIgnoringSafeAreaSupporting
        let safeAreasToIgnore = hasExplicitSafeAreas ? UIView.edgesIgnoringSafeArea(for: rootView) : []
        let container = rootView.ignoresSafeArea(edges: safeAreasToIgnore)
        if !hasExplicitSafeAreas {
            container.backgroundColor = .systemBackground
        }
        self.view = container
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
}

