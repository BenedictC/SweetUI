import UIKit
import Combine


// MARK: - CollectionViewDataSource propertyWrapper

@propertyWrapper
public struct CollectionViewDataSource<SectionIdentifier: Hashable, ItemValue: Hashable> {

    // MARK: Type

    public typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue>

    public final class Storage {

        fileprivate var initialSnapshot: Snapshot?

        public var dataSource: CollectionViewDiffableDataSource<SectionIdentifier, ItemValue>! {
            if _dataSource == nil {
                log.fault("Accessed dataSource of CollectionViewDataSource before the dataSource has been initialized.")
            }
            return _dataSource
        }
        private var _dataSource: CollectionViewDiffableDataSource<SectionIdentifier, ItemValue>!
        public var snapshotPublisher: AnyPublisher<Snapshot, Never> { _dataSource.snapshotPublisher }

        internal func initialize(collectionView: UICollectionView, cellProvider: @escaping CollectionViewDiffableDataSource<SectionIdentifier, ItemValue>.CellProvider) -> UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue> {
            assert(_dataSource == nil)
            self._dataSource = CollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: cellProvider)
            if let initialSnapshot {
                _dataSource.apply(initialSnapshot)
            }
            initialSnapshot = nil
            return _dataSource
        }

        public func initialize(for collectionView: UICollectionView) {
            // This method is a weird hack for lazy loaded collectionViews.
            // It's only needs to be called when the dataSource is accessed before the collectionView is loaded.
            //
            // It doesn't actually perform initialize, the initialization occurs in the init of collectionView, this
            // method is just allows that to occur in an explicit manner.
            assert(self._dataSource != nil)
        }

        public func newSnapshot() -> Snapshot {
            NSDiffableDataSourceSnapshot()
        }
    }


    // MARK: Properties

    public let projectedValue = Storage()

    public var wrappedValue: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue> {
        get {
            guard let dataSource = projectedValue.dataSource else {
                return projectedValue.initialSnapshot ?? NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue>()
            }
            return dataSource.snapshot()
        }
        set {
            guard let dataSource = projectedValue.dataSource else {
                projectedValue.initialSnapshot = newValue
                return
            }
            dataSource.apply(newValue)
        }
    }


    // MARK: Instance life cycle

    public init() { }
}



// MARK: - CollectionViewDiffableDataSource

public final class CollectionViewDiffableDataSource<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {

    public typealias IndexTitleAndIndexPath = (indexTitle: String, indexPath: IndexPath)
    public typealias IndexTitleAndIndexPathProvider = (NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>) -> [IndexTitleAndIndexPath]

    private weak var collectionView: UICollectionView?

    public var indexTitleProvider: IndexTitleAndIndexPathProvider? {
        didSet { collectionView?.reloadData() }
    }
    private var indexTitlesAndIndexPaths: [IndexTitleAndIndexPath]?
    private let snapshotSubject = CurrentValueSubject<NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, Never>(NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>())
    public var snapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, Never> { snapshotSubject.eraseToAnyPublisher() }


    override init(collectionView: UICollectionView, cellProvider: @escaping CellProvider) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.collectionView = collectionView
    }

    @available(iOS 15, *)
    public override func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, completion: (() -> Void)? = nil) {
        super.applySnapshotUsingReloadData(snapshot, completion: completion)
        snapshotSubject.send(snapshot)
    }

    public override func apply(_ fresh: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        super.apply(fresh, animatingDifferences: animatingDifferences, completion: completion)
        snapshotSubject.send(fresh)
    }

    @MainActor
    public override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        guard let indexTitleProvider else {
            indexTitlesAndIndexPaths = nil
            return nil
        }
        let snapshot = self.snapshot()
        let indexTitlesAndIndexPaths = indexTitleProvider(snapshot)
        self.indexTitlesAndIndexPaths = indexTitlesAndIndexPaths
        return indexTitlesAndIndexPaths.map { $0.indexTitle }
    }

    public override func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        guard let indexTitlesAndIndexPaths else {
            // TODO: This shouldn't happen, but is this safe?
            return IndexPath(item: 0, section: index)
        }
        return indexTitlesAndIndexPaths[index].indexPath
    }
}


// MARK: - Backport for iOS 14

internal extension UICollectionViewDiffableDataSource {

    func sectionIdentifier(forSectionAtIndex sectionIndex: Int) -> SectionIdentifierType? {
        let snapshot = self.snapshot()
        guard sectionIndex < snapshot.sectionIdentifiers.count else {
            return nil
        }
        return snapshot.sectionIdentifiers[sectionIndex]
    }
}
