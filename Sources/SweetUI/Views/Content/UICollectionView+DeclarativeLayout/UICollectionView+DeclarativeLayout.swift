import Foundation
import UIKit
import Combine


extension UICollectionView {

    convenience init<SectionIdentifier: Hashable, ItemValue: Hashable>(
        dataSource dataSourceStorage:  CollectionViewDataSource<SectionIdentifier, ItemValue>.Storage,
        delegate: UICollectionViewDelegate? = nil,
        layout: UICollectionViewLayout,
        cellProvider: @escaping UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>.CellProvider,
        supplementaryViewProvider: @escaping UICollectionViewDiffableDataSourceReferenceSupplementaryViewProvider
    ) {
        self.init(frame: .zero, collectionViewLayout: layout)

        // Attached data & delegate
        let dataSource = dataSourceStorage.initialize(collectionView: self, cellProvider: cellProvider)
        dataSource.supplementaryViewProvider = supplementaryViewProvider
        self.delegate = delegate
    }
}


public extension UICollectionView {

    convenience init<SectionIdentifier: Hashable, ItemValue: Hashable, Strategy: CollectionViewStrategy>(
        dataSource dataSourceStorage:  CollectionViewDataSource<SectionIdentifier, ItemValue>.Storage,
        delegate: UICollectionViewDelegate? = nil,
        layout strategyBuilder: () -> Strategy
    ) where Strategy.SectionIdentifier == SectionIdentifier,
            Strategy.ItemValue == ItemValue
    {
        // Init with placeholder layout
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        //Create strategy and dataSource
        let strategy = strategyBuilder()

        // Attached data & delegate
        let dataSource = dataSourceStorage.initialize(collectionView: self, cellProvider: { collectionView, indexPath, itemValue in
            let dataSource = collectionView.dataSource as! UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>
            guard let sectionIdentifier = dataSource.sectionIdentifier(forSectionAtIndex: indexPath.section) else {
                preconditionFailure("Invalid section index")
            }
            let cell = strategy.cell(for: collectionView, itemValue: itemValue, in: sectionIdentifier, at: indexPath)
            return cell
        })
        dataSource.supplementaryViewProvider = { [weak dataSource] collectionView, elementKind, indexPath in
            guard let dataSource else {
                fatalError()
            }
            let view = strategy.supplementaryView(for: collectionView, elementKind: elementKind, at: indexPath, dataSource: dataSource)
            return view
        }
        self.delegate = delegate

        // Set the final layout
        let layout = strategy.makeLayout(dataSource: dataSource)
        strategy.registerReusableViews(in: self, layout: layout)
        self.collectionViewLayout = layout
    }
}


// MARK: - CollectionViewDataSource propertyWrapper

// TODO: Add support for indexTitles: https://stackoverflow.com/questions/69936255/how-do-i-support-the-fast-scrolling-scrubber-using-uicollectionviewdiffabledatas

@propertyWrapper
public struct CollectionViewDataSource<SectionIdentifier: Hashable, ItemValue: Hashable> {

    // MARK: Type

    public final class Storage {

        public private(set) var dataSource: CollectionViewDiffableDataSource<SectionIdentifier, ItemValue>!
        public var snapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue>, Never> { dataSource.snapshotPublisher }

        fileprivate func initialize(collectionView: UICollectionView, cellProvider: @escaping CollectionViewDiffableDataSource<SectionIdentifier, ItemValue>.CellProvider) -> UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue> {
            self.dataSource = CollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: cellProvider)
            return dataSource
        }
    }


    // MARK: Properties

    public let projectedValue = Storage()
    public var wrappedValue: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue> {
        get {
            guard let dataSource = projectedValue.dataSource else {
                print("⚠️ Attempted to access CollectionViewDataSource.dataSource before collectionView has been initialized. Returning empty snapshot.")
                return NSDiffableDataSourceSnapshot()
            }
            return dataSource.snapshot()
        }
        set {
            guard let dataSource = projectedValue.dataSource else {
                print("⚠️ Attempted to access CollectionViewDataSource.dataSource before collectionView has been initialized. New value will be discarded.")
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
    private let snapshotSubject = PassthroughSubject<NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, Never>()
    public var snapshotPublisher: AnyPublisher<NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, Never> { snapshotSubject.eraseToAnyPublisher() }


    override init(collectionView: UICollectionView, cellProvider: @escaping CellProvider) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.collectionView = collectionView
    }

    public override func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        "TODO: Do we need to override any of the other apply methods?"
        super.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        snapshotSubject.send(snapshot)
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
