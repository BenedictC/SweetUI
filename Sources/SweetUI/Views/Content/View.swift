import Foundation
import UIKit


// MARK: - View

public typealias View<ViewModel> = _View<ViewModel> & ViewBodyProvider


// MARK: - Implementation

open class _View<ViewModel>: UIView, _ViewIsAvailableProviderImplementation, _TraitCollectionDidChangeProviderImplementation {

    // MARK: Types

    typealias ViewModel = ViewModel

    
    // MARK: Properties

    public var viewModel: ViewModel! {
        guard let anyViewModel = anyObjectViewModel ?? anyViewModel,
              let viewModel = anyViewModel as? ViewModel else {
            preconditionFailure("viewModel must be provided at init. _View weakly retains its viewModel and expects it to live for the duration of the _View instances existence.")
        }
        return viewModel
    }
    var anyViewModel: Any?
    weak var anyObjectViewModel: AnyObject?
    let viewIsAvailableProviderStorage = ViewIsAvailableProviderStorage()
    let traitCollectionDidChangeProviderStorage = TraitCollectionDidChangeProviderStorage()


    // MARK: Instance life cycle

    required public init(viewModel: ViewModel) {
        super.init(frame: .zero)

        let isReferenceType = object_isClass(type(of: viewModel as Any))
        if isReferenceType {
            anyObjectViewModel = viewModel as AnyObject
        } else {
            anyViewModel = viewModel
        }

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

public extension _View where ViewModel == Void {

    convenience init(voidViewModel: Void = ()) {
        self.init(viewModel: voidViewModel)
    }
}
