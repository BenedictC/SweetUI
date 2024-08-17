import Foundation
import UIKit
import Combine


// MARK: - View

public typealias Control = _Control & ViewBodyProvider


// MARK: - Implementation

open class _Control: UIControl, TraitCollectionChangesProvider {

    // MARK: Properties

    private lazy var traitCollectionChangesController = TraitCollectionChangesController(initialTraitCollection: traitCollection)
    public var traitCollectionChanges: AnyPublisher<TraitCollectionChanges, Never> { traitCollectionChangesController.traitCollectionChanges }


    // TODO: Add a publisher that emits state changes
    

    // MARK: Instance life cycle

    public init() {
        super.init(frame: .zero)
        guard let bodyProvider = self as? _ViewBodyProvider else {
            preconditionFailure("_Control subclasses must conform to _ViewBodyProvider")
        }
        bodyProvider.initializeBodyHosting()
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
