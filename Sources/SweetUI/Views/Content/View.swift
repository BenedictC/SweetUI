import Foundation
import UIKit


public typealias View = _View & ViewBodyProvider


// MARK: - Implementation

open class _View: UIView, TraitCollectionChangesProvider {

    // MARK: Properties

    private lazy var traitCollectionChangesController = TraitCollectionChangesController(initialTraitCollection: traitCollection)
    public var traitCollectionChanges: AnyPublisher<TraitCollectionChanges, Never> { traitCollectionChangesController.traitCollectionChanges }


    // MARK: Instance life cycle

    public init() {
        super.init(frame: .zero)
        guard let bodyProvider = self as? _ViewBodyProvider else {
            preconditionFailure("_View subclasses must conform to _ViewBodyProvider")
        }
        bodyProvider.initializeBodyHosting()
        bodyProvider.awake()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: View events

    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        traitCollectionChangesController.send(previous: previous, current: traitCollection)
    }
}
