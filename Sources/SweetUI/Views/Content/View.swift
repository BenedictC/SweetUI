import Foundation
import UIKit


// MARK: - View

public typealias View<ViewModel> = _View<ViewModel> & ViewBodyProvider & ViewModelProvider


// MARK: - Implementation

open class _View<ViewModel>: UIView, _TraitCollectionPublisherProviderImplementation {

    // MARK: Types

    public typealias ViewModel = ViewModel

    
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
    public private(set) lazy var _traitCollectionPublisherController = TraitCollectionPublisherController(initialTraitCollection: traitCollection)


    // MARK: Instance life cycle

    public init(viewModel: ViewModel) {
        super.init(frame: .zero)

        let isViewValueSubject = viewModel is any ViewValueSubject
        let isReferenceType = object_isClass(type(of: viewModel as Any))
        let shouldRetainViewModel = isViewValueSubject || !isReferenceType
        if shouldRetainViewModel {
            anyViewModel = viewModel
        } else {
            anyObjectViewModel = viewModel as AnyObject
        }
        guard let bodyProvider = self as? _ViewBodyProvider else {
            preconditionFailure("_View subclasses must conform to _ViewBodyProvider")
        }
        bodyProvider.initializeBodyHosting()
    }

    public convenience init(voidViewModel: Void = ()) where ViewModel == Void {
        self.init(viewModel: ())
    }

    public convenience init(initialValue: ViewModel.Output) where ViewModel: ViewValueSubject {
        let viewModel = ViewModel(initialValue)
        self.init(viewModel: viewModel)
    }

    public convenience init(initialValue: ViewModel.Output = .default) where ViewModel: ViewValueSubject, ViewModel.Output: Defaultable {
        let viewModel = ViewModel(initialValue)
        self.init(viewModel: viewModel)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: View events

    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        _traitCollectionPublisherController.send(previous: previous, current: traitCollection)
    }
}
