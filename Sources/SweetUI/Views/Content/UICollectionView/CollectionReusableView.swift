import UIKit


public typealias CollectionReusableView = _CollectionReusableView & ViewBodyProvider


open class _CollectionReusableView: UICollectionReusableView, ReuseIdentifiable {

    // MARK: Properties

    fileprivate lazy var defaultCancellableStorage = CancellableStorage()


    // MARK: Instance life cycle

    public required override init(frame: CGRect) {
        super.init(frame: frame)
        Self.initializeBodyHosting(of: self)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - CancellableStorageProvider defaults

extension CancellableStorageProvider where Self: _CollectionReusableView {

    public var cancellableStorage: CancellableStorage { defaultCancellableStorage }
}


// MARK: - ViewBodyProvider

extension _CollectionReusableView {

    public func arrangeBody(_ body: UIView, in container: UIView) {
        body.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(body)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: container.topAnchor),
            body.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            // Priority is less than required to break cleanly if the content resizes without invalidating the
            // collectionView layout.
            body.bottomAnchor.constraint(equalTo: container.bottomAnchor).priority(.almostRequired),
            body.trailingAnchor.constraint(equalTo: container.trailingAnchor).priority(.almostRequired),
        ])
    }
}
