import Foundation
import UIKit
import Combine


// MARK: - CollectionViewLayoutStrategy

@available(iOS 14, *)
public protocol CollectionViewLayoutStrategy {

    associatedtype SectionIdentifier: Hashable
    associatedtype ItemIdentifier: Hashable
    typealias DiffableDataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>

    var behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemIdentifier> { get }

    func registerReusableViews(in collectionView: UICollectionView, layout: UICollectionViewLayout)
    func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionViewLayout
    func cell(for collectionView: UICollectionView, ItemIdentifier: ItemIdentifier, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell
    func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionReusableView
}


// MARK: - CollectionViewLayoutBehaviors

@available(iOS 14, *)
public struct CollectionViewLayoutBehaviors<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    public typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    public typealias DiffableDataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>
    public typealias IndexElement = DiffableDataSource.IndexElement
    public typealias IndexElementsProvider = DiffableDataSource.IndexElementsProvider

    public let indexElementsProvider: IndexElementsProvider?
    public let reorderHandlers: DiffableDataSource.ReorderingHandlers?
    public let sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>?

    public init(
        indexElementsProvider: IndexElementsProvider?,
        reorderHandlers: DiffableDataSource.ReorderingHandlers?,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>?
    ) {
        self.indexElementsProvider = indexElementsProvider
        self.reorderHandlers = reorderHandlers
        self.sectionSnapshotHandlers = sectionSnapshotHandlers
    }
}


// MARK: - ReusableViewConfigurable

public protocol ReusableViewConfigurable: UICollectionReusableView {

    associatedtype Value = Void

    func configure(using value: Value)
}

public extension ReusableViewConfigurable where Value == Void {

    func configure(using value: Value) {
        // Do nothing
    }
}


// MARK: - BoundarySupplementaryComponent/AnyBoundarySupplementaryComponent

public protocol BoundarySupplementaryComponent {

    associatedtype SectionIdentifier

    var elementKind: String { get }

    func registerSupplementaryView(in collectionView: UICollectionView)
    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem
    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView
}



public struct AnyBoundarySupplementaryComponent<SectionIdentifier>: BoundarySupplementaryComponent {

    public let elementKind: String
    let registerSupplementaryViewHandler: (_ collectionView: UICollectionView) -> Void
    let makeLayoutBoundarySupplementaryItemHandler: () -> NSCollectionLayoutBoundarySupplementaryItem
    let makeSupplementaryViewHandler: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ sectionIdentifier: SectionIdentifier) -> UICollectionReusableView

    init(
        elementKind: String,
        registerSupplementaryViewHandler: @escaping (_ collectionView: UICollectionView) -> Void,
        makeLayoutBoundarySupplementaryItemHandler: @escaping () -> NSCollectionLayoutBoundarySupplementaryItem,
        makeSupplementaryViewHandler: @escaping (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ sectionIdentifier: SectionIdentifier) -> UICollectionReusableView
    ) {
        self.elementKind = elementKind
        self.registerSupplementaryViewHandler = registerSupplementaryViewHandler
        self.makeLayoutBoundarySupplementaryItemHandler = makeLayoutBoundarySupplementaryItemHandler
        self.makeSupplementaryViewHandler = makeSupplementaryViewHandler
    }

    init<T: BoundarySupplementaryComponent>(erased: T) where T.SectionIdentifier == SectionIdentifier {
        self.elementKind = erased.elementKind
        registerSupplementaryViewHandler = erased.registerSupplementaryView(in:)
        makeLayoutBoundarySupplementaryItemHandler = erased.makeLayoutBoundarySupplementaryItem
        makeSupplementaryViewHandler = erased.makeSupplementaryView(for:indexPath:sectionIdentifier:)
    }

    public func registerSupplementaryView(in collectionView: UICollectionView) {
        registerSupplementaryViewHandler(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        makeLayoutBoundarySupplementaryItemHandler()
    }

    public func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        makeSupplementaryViewHandler(collectionView, indexPath, sectionIdentifier)
    }
}
