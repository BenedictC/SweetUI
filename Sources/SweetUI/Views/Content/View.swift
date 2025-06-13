import Foundation
import Combine
import UIKit


public typealias View = _View & ViewBodyProvider


// MARK: - Implementation

open class _View: UIView, TraitCollectionChangesProvider {
    
    // MARK: Types
    
    public enum CancellableKey {
        public static let awake = CancellableStorageKey.unique()
        public static let loadBody = CancellableStorageKey.unique()
    }
    
    
    // MARK: Properties
    
    private lazy var traitCollectionChangesController = TraitCollectionChangesController(initialTraitCollection: traitCollection)
    public var traitCollectionChanges: AnyPublisher<TraitCollectionChanges, Never> { traitCollectionChangesController.traitCollectionChanges }
    fileprivate lazy var defaultCancellableStorage = CancellableStorage()

    
    // MARK: Instance life cycle
    
    public init() {
        super.init(frame: .zero)
        Self.initializeBodyHosting(of: self)
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


// MARK: - CancellableStorageProvider defaults

extension CancellableStorageProvider where Self: View {

    public var cancellableStorage: CancellableStorage { defaultCancellableStorage }
}


// MARK: - ViewBodyProvider

public extension _View {

    func arrangeBody(_ body: UIView, in container: UIView) {
        container.addAndFill(subview: body, overrideEdgesIgnoringSafeArea: nil)
    }
}
