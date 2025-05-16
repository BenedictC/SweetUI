import Foundation
import UIKit


// MARK: - ConfigurableCollectionViewCell

public protocol ConfigurableCollectionViewCell: UICollectionViewCell, ReusableViewConfigurable {
}


// MARK: - CollectionViewCell

public typealias CollectionViewCell = _CollectionViewCell & ViewBodyProvider & ConfigurableCollectionViewCell


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
        bodyProvider.storeCancellables(with: View.CancellableKey.awake) {
            bodyProvider.awake()
        }
        bodyProvider.storeCancellables(with: View.CancellableKey.loadBody) {
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


// MARK: - ViewBodyProviding

extension _CollectionViewCell {

    public static func arrangeBody(_ body: UIView, in container: UIView) {
        body.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(body)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: container.topAnchor),
            body.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            body.bottomAnchor.constraint(equalTo: container.bottomAnchor).priority(.almostRequired),
            body.trailingAnchor.constraint(equalTo: container.trailingAnchor).priority(.almostRequired),
        ])
    }
}
