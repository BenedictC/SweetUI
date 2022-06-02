import Foundation
import UIKit


public typealias View = _View & ViewBodyProvider & ViewModelConnectionProvider


open class _View: UIView, _ConnectionProviderImplementation, TraitCollectionDidChangeProvider {

    // MARK: Properties

    var anyViewModel: Any?
    weak var anyObjectViewModel: AnyObject?
    let connectionProviderStorage = ConnectionProviderStorage()
    var traitCollectionDidChangeHandlers = [(UITraitCollection?, UITraitCollection) -> Bool]()
    

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
//        guard let self = self as? ViewConnectionProvider else {
//            preconditionFailure()
//        }
        let shouldAttachImmediately = self.window == nil && window != nil
        if shouldAttachImmediately {
            self.updateConnectionHandlers(shouldConnect: true)
        }
        // Schedule an update for the next tick of the run loop
        // We don't update immediately because the view could be moving to another window
        DispatchQueue.main.async {
            let shouldConnect = !self.areConnectionsActive && self.window != nil
            let shouldDisconnect = self.window == nil
            if shouldConnect || shouldDisconnect {
                let shouldConnect = self.window != nil
                self.updateConnectionHandlers(shouldConnect: shouldConnect)
            }
        }
    }

    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        let current = self.traitCollection
        self.traitCollectionDidChangeHandlers = traitCollectionDidChangeHandlers.filter { $0(previous, current) }
    }
}


// MARK: - TraitCollectionDidChangeProvider

extension _View {

    public func addTraitCollectionDidChangeHandler(_ handler: @escaping (UITraitCollection?, UITraitCollection) -> Bool) {
        traitCollectionDidChangeHandlers.append(handler)
    }
}


// MARK: - ViewModel

public extension ViewModelConnectionProvider where Self: _View {

    var viewModel: ViewModel? {
        get { (anyObjectViewModel ?? anyViewModel) as! ViewModel? }
        set {
            if let newValue = newValue as? AnyObject  {
                anyViewModel = nil
                anyObjectViewModel = newValue
            } else {
                anyViewModel = newValue
                anyObjectViewModel = nil
            }
            let shouldConnect = window != nil
            updateConnectionHandlers(shouldConnect: shouldConnect)
        }
    }

    init(viewModel: ViewModel) {
        self.init()
        self.viewModel = viewModel
    }
}


@available(*, unavailable)
public extension ViewModelConnectionProvider where Self: _View, ViewModel == Void {

    var viewModel: ViewModel? {
        get { anyViewModel as! ViewModel? }
        set { anyViewModel = newValue }
    }

    init(viewModel: ViewModel) {
        self.init()
    }
}
