import Foundation
import UIKit


public typealias CollectionViewCell = _CollectionViewCell & ViewBodyProvider


open class _CollectionViewCell: UICollectionViewCell, ReuseIdentifiable {

    // MARK: Properties

    public var bodyContainer: UIView { contentView }
    fileprivate lazy var defaultCancellableStorage = CancellableStorage()


    // MARK: Instance life cycle

    public required override init(frame: CGRect) {
        super.init(frame: frame)
        guard let bodyProvider = self as? _ViewBodyProvider else {
            preconditionFailure("_CollectionViewCell subclasses must conform to _ViewBodyProvider")
        }
        bodyProvider.collectCancellables(with: View.CancellableKey.awake) {
            bodyProvider.awake()
        }
        bodyProvider.collectCancellables(with: View.CancellableKey.loadBody) {
            bodyProvider.initializeBodyHosting()
        }
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - CancellableStorageProvider defaults

extension CancellableStorageProvider where Self: _CollectionViewCell {

    public var cancellableStorage: CancellableStorage { defaultCancellableStorage }
}
