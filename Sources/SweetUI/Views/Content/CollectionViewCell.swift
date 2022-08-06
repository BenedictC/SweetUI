import Foundation
import UIKit


public typealias CollectionViewCell = UICollectionViewCell & ViewBodyProvider


open class _CollectionViewCell: UICollectionViewCell {

    // MARK: Properties

    public var bodyContainer: UIView { contentView }


    // MARK: Instance life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        guard let bodyProvider = self as? _ViewBodyProvider else {
            preconditionFailure("_CollectionViewCell subclasses must conform to _ViewBodyProvider")
        }
        bodyProvider.initializeBodyHosting()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
