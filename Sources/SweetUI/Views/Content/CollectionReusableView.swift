import UIKit


public typealias CollectionReusableView = _CollectionReusableView & ViewBodyProvider


open class _CollectionReusableView: UICollectionReusableView, ReuseIdentifiable {

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
