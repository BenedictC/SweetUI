import UIKit


@available(*, unavailable, message: "CollectionViewDataSource has been replaced with CollectionViewSnapshot.")
public typealias CollectionViewDataSource = CollectionViewSnapshot


@available(iOS 14, *)
@propertyWrapper
public struct CollectionViewSnapshot<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    // MARK: Types

    public typealias DataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    public typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifier>

    public class Coordinator {

        // MARK: Types

        public enum UpdateMode {
            case animated
            case unanimated
            @available(iOS 15, *)
            case reload
        }

        public enum Update {
            case layout(Snapshot, mode: UpdateMode)
            case section(SectionSnapshot, section: SectionIdentifier, animated: Bool)
        }


        // MARK: Properties

        public var snapshot: Snapshot { snapshotSubject.value }
        public var snapshotPublisher: some Publisher<Snapshot, Never> { snapshotSubject }

        private let snapshotSubject: CurrentValueSubject<Snapshot, Never>
        private weak var collectionView: UICollectionView?
        private var dataSource: DataSource?
        private var pendingSectionSnapshots = [(snapshot: SectionSnapshot, identifier: SectionIdentifier)]()


        // MARK: Instance life cycle

        init(snapshot: Snapshot) {
            self.snapshotSubject = CurrentValueSubject(snapshot)
        }


        // MARK: CollectionView registration

        internal func register(collectionView: UICollectionView, cellProvider: @escaping DataSource.CellProvider) -> DataSource? {
            let isAvailableForRegistration = self.collectionView == nil
            guard isAvailableForRegistration else {
                log.error("Attempt to register multiple UICollectionView instances with a CollectionViewSnapshot.")
                return nil
            }

            self.collectionView = collectionView

            let dataSource = DataSource(collectionView: collectionView, cellProvider: cellProvider)
            let initialSnapshot = snapshot
            dataSource.apply(initialSnapshot, animatingDifferences: false)
            self.dataSource = dataSource

            for pendingSectionSnapshot in pendingSectionSnapshots {
                self.applySectionSnapshot(pendingSectionSnapshot.snapshot, to: pendingSectionSnapshot.identifier, animated: false)
            }
            pendingSectionSnapshots = []

            return dataSource
        }


        // MARK: Snapshot updating

        public func applySnapshot(_ snapshot: Snapshot, withMode updateMode: UpdateMode = .animated, completion: ((Snapshot) -> Void)? = nil) {
            // If the dataSource hasn't been initialised then
            guard let dataSource else {
                self.pendingSectionSnapshots = []
                // Send the new value to the complete before updating the subject so that both values will be available to completion()
                completion?(snapshot)
                self.snapshotSubject.send(snapshot)
                return
            }

            let dataSourceCompletion = { () -> Void in
                let updatedSnapshot = dataSource.snapshot()
                // Send the new value to the complete before updating the subject so that both values will be available to completion()
                completion?(updatedSnapshot)
                self.snapshotSubject.send(updatedSnapshot)
            }
            switch updateMode {
            case .animated:
                dataSource.apply(snapshot, animatingDifferences: true, completion: dataSourceCompletion)

            case .unanimated:
                dataSource.apply(snapshot, animatingDifferences: false, completion: dataSourceCompletion)

            case .reload:
                if #available(iOS 15, *) {
                    dataSource.applySnapshotUsingReloadData(snapshot, completion: dataSourceCompletion)
                } else {
                    dataSource.apply(snapshot, animatingDifferences: false, completion: dataSourceCompletion)
                }
            }
        }

        public func applySnapshot(_ snapshot: Snapshot, withMode updateMode: UpdateMode = .animated) async -> Snapshot {
            await withCheckedContinuation { continuation in
                applySnapshot(snapshot, withMode: updateMode, completion: { continuation.resume(returning: $0) })
            }
        }


        // MARK: SectionSnapshot updating

        /// Returns nil if the dataSource has not yet been initialized otherwise returns the updated snapshot
        public func applySectionSnapshot(_ sectionSnapshot: SectionSnapshot, to sectionIdentifier: SectionIdentifier, animated: Bool = true, completion: ((Snapshot?) -> Void)? = nil) {
            // If the dataSource hasn't been initialised then
            guard let dataSource else {
                pendingSectionSnapshots.append((sectionSnapshot, sectionIdentifier))
                completion?(nil)
                return
            }

            let dataSourceCompletion = { () -> Void in
                let updatedSnapshot = dataSource.snapshot()
                // Send the new value to the complete before updating the subject so that both values will be available to completion()
                completion?(updatedSnapshot)
                self.snapshotSubject.send(updatedSnapshot)
            }
            dataSource.apply(sectionSnapshot, to: sectionIdentifier, animatingDifferences: animated, completion: dataSourceCompletion)
        }

        public func applySectionSnapshot(_ sectionSnapshot: SectionSnapshot, to sectionIdentifier: SectionIdentifier, animated: Bool = true) async -> Snapshot? {
            await withCheckedContinuation { continuation in
                applySectionSnapshot(sectionSnapshot, to: sectionIdentifier, animated: animated, completion: { continuation.resume(returning: $0) })
            }
        }


        // MARK: Factory

        public func newSnapshot() -> Snapshot {
            Snapshot()
        }

        @discardableResult
        public func buildAndApplySnapshot(withMode updateMode: UpdateMode = .animated, _ builder: (inout Snapshot) -> Void) -> Snapshot {
            var new = Snapshot()
            builder(&new)
            self.applySnapshot(new, withMode: updateMode)
            return new
        }
    }


    // MARK: Properties

    public let projectedValue: Coordinator
    public var wrappedValue: Snapshot {
        get { projectedValue.snapshot }
        set { projectedValue.applySnapshot(newValue, withMode: .animated) }
    }


    // MARK: Instance life cycle

    public init(wrappedValue: Snapshot = Snapshot()) {
        self.projectedValue = Coordinator(snapshot: wrappedValue)
    }
}
