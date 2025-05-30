import UIKit




// MARK: - CollectionViewController

@available(iOS 14, *)
public typealias CollectionViewController = _CollectionViewController & CollectionViewControllerRequirements


// MARK: - Associated Types

@available(iOS 14, *)
public protocol CollectionViewControllerRequirements: _ViewControllerRequirements {
    associatedtype View: UIView

    associatedtype SectionIdentifier: Hashable
    associatedtype ItemIdentifier: Hashable
    associatedtype LayoutStrategy: CollectionViewLayoutStrategy<SectionIdentifier, ItemIdentifier>


    var rootView: View { get }

    var snapshotCoordinator: CollectionViewSnapshotCoordinator<SectionIdentifier, ItemIdentifier> { get }
    var layout: LayoutStrategy { get }
    var collectionView: UICollectionView { get }
}


@available(iOS 14, *)
public extension CollectionViewControllerRequirements where Self: _CollectionViewController {

    var rootView: UICollectionView { collectionView }
    var _rootView: UIView { rootView }

    var collectionView: UICollectionView {
        if let defaultCollectionView {
            return defaultCollectionView
        }
        let collectionView = UICollectionView(
            snapshotCoordinator: snapshotCoordinator,
            delegate: self,
            layout: { layout }
        )
        self.defaultCollectionView = collectionView

        return collectionView
    }

    var snapshotCoordinator: CollectionViewSnapshotCoordinator<SectionIdentifier, ItemIdentifier> {
        if let coordinator = defaultSnapshotCoordinator as? CollectionViewSnapshotCoordinator<SectionIdentifier, ItemIdentifier> {
            return coordinator
        }
        let coordinator = CollectionViewSnapshotCoordinator<SectionIdentifier, ItemIdentifier>()
        self.defaultSnapshotCoordinator = coordinator
        return coordinator
    }

    var cancellableStorage: CancellableStorage { defaultCancellableStorage }
}


open class _CollectionViewController: _ViewController {

    var defaultSnapshotCoordinator: AnyObject?
    var defaultCollectionView: UICollectionView?
}


extension _CollectionViewController: UICollectionViewDelegate {

}
