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
    private let stateSubject: CurrentValueSubject<UIControl.State, Never>
    public let stateChanges: AnyPublisher<UIControl.State, Never>

    override public var isEnabled: Bool {
        get { super.isEnabled }
        set { super.isEnabled = newValue; notifyOfStateChange() }
    }
    override public var isSelected: Bool {
        get { super.isSelected }
        set { super.isSelected = newValue; notifyOfStateChange() }
    }
    override public var isHighlighted: Bool {
        get { super.isHighlighted }
        set { super.isHighlighted = newValue; notifyOfStateChange() }
    }
    override public var isHidden: Bool {
        get { super.isHidden }
        set { super.isHidden = newValue; notifyOfStateChange() }
    }


    // MARK: Instance life cycle

    public init() {
        let stateSubject = CurrentValueSubject<UIControl.State, Never>(.normal)
        self.stateSubject = stateSubject
        self.stateChanges = stateSubject.eraseToAnyPublisher()
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

    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.beginTracking(touch, with: event)
        notifyOfStateChange()
        return result
    }

    public override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        notifyOfStateChange()
    }

    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        notifyOfStateChange()
    }


    // MARK: State management

    private func notifyOfStateChange() {
        stateSubject.send(state)        
    }
}
