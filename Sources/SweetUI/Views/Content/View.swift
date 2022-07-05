import Foundation
import UIKit


public typealias View = _View & ViewBodyProvider & ViewModelProvider


// MARK: - ViewModelConnectionProvider

public protocol ViewModelProvider {

    associatedtype ViewModel = Void

    var viewModel: ViewModel! { get }
}


open class _View: UIView, _ViewIsAvailableProviderImplementation, _TraitCollectionDidChangeProviderImplementation {

    // MARK: Properties

    var anyViewModel: Any?
    weak var anyObjectViewModel: AnyObject?
    let viewIsAvailableProviderStorage = ViewIsAvailableProviderStorage()
    let traitCollectionDidChangeProviderStorage = TraitCollectionDidChangeProviderStorage()


    // MARK: Instance life cycle

    required public init() {
        super.init(frame: .zero)

        guard let bodyProvider = self as? _ViewBodyProvider else {
            preconditionFailure("_View subclasses must conform to _ViewBodyProvider")
        }
        bodyProvider.initializeBody()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: View events

    open override func willMove(toWindow window: UIWindow?) {
        super.willMove(toWindow: window)

        // When a VC animates their view is moved to a transitionary window
        // which means this gets fired more often than expected.
//        guard let self = self as? ViewIsAvailableProvider else {
//            preconditionFailure()
//        }
        let shouldCollectCancellables = self.window == nil && window != nil
        if shouldCollectCancellables {
            self.updateViewIsAvailableHandlers(isAvailable: true)
        }
        // Schedule an update for the next tick of the run loop
        // We don't update immediately because the view could be moving to another window
        DispatchQueue.main.async {
            let didBecomeAvailable = !self.hasViewAvailabilityCancellables && self.window != nil
            let didBecomeUnavailable = self.window == nil
            if didBecomeAvailable || didBecomeUnavailable {
                let isAvailable = self.window != nil
                self.updateViewIsAvailableHandlers(isAvailable: isAvailable)
            }
        }
    }

    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        let current = self.traitCollection
        invokeTraitCollectionDidChangeHandlers(previous: previous, current: current)
    }
}


// MARK: - ViewModel

public extension ViewModelProvider where Self: _View {

    private(set) var viewModel: ViewModel! {
        get {
            "TODO: If ViewModel: AnyObject and anyObjectViewModel == nil then fatalError()"
            return (anyObjectViewModel ?? anyViewModel) as! ViewModel?
        }
        set {
            if let newValue = newValue as? AnyObject  {
                anyViewModel = nil
                anyObjectViewModel = newValue
            } else {
                anyViewModel = newValue
                anyObjectViewModel = nil
            }
            let shouldCollectCancellables = window != nil
            updateViewIsAvailableHandlers(isAvailable: shouldCollectCancellables)
        }
    }

    init(viewModel: ViewModel) {
        self.init()
        self.viewModel = viewModel
    }
}


@available(*, unavailable)
public extension ViewModelProvider where Self: _View, ViewModel == Void {

    private(set) var viewModel: ViewModel! {
        get { anyViewModel as! ViewModel? }
        set { anyViewModel = newValue }
    }

    init(viewModel: ViewModel) {
        self.init()
        anyViewModel = ()
    }
}
