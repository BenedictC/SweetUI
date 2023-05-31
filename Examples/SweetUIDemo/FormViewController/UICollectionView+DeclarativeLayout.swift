import Foundation
import UIKit
import SweetUI


extension UICollectionView {

    convenience init<SectionIdentifier: Hashable, ItemValue: Hashable>(
        dataSource dataSourceStorage:  CollectionViewDataSource<SectionIdentifier, ItemValue>.Storage,
        layout: UICollectionViewLayout,
        cellProvider: @escaping UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>.CellProvider,
        supplementaryViewProvider: @escaping UICollectionViewDiffableDataSourceReferenceSupplementaryViewProvider
    ) {
        // Init with placeholder layout
        self.init(frame: .zero, collectionViewLayout: layout)

        // Attached data
        let dataSource = dataSourceStorage.initialize(collectionView: self, cellProvider: cellProvider)
        dataSource.supplementaryViewProvider = supplementaryViewProvider
    }
}


extension UICollectionView {

    convenience init<SectionIdentifier: Hashable, ItemValue: Hashable, Strategy: CollectionViewStrategy>(
        dataSource dataSourceStorage:  CollectionViewDataSource<SectionIdentifier, ItemValue>.Storage,
        layout strategyBuilder: () -> Strategy
    ) where Strategy.SectionIdentifier == SectionIdentifier,
            Strategy.ItemValue == ItemValue
    {
        // Init with placeholder layout
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        //Create strategy and dataSource
        let strategy = strategyBuilder()
        strategy.registerReusableViews(in: self)

        // Attached data
        let dataSource = dataSourceStorage.initialize(collectionView: self, cellProvider: { collectionView, indexPath, itemValue in
            let dataSource = collectionView.dataSource as! UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>
            guard let sectionIdentifier = dataSource.sectionIdentifier(for: indexPath.section) else {
                preconditionFailure("Unable to retrieve sectionIdentifier for section at index \(indexPath.section)")
            }
            let cell = strategy.cell(for: collectionView, itemValue: itemValue, in: sectionIdentifier, at: indexPath)
            return cell
        })
        dataSource.supplementaryViewProvider = { [weak dataSource] collectionView, elementKind, indexPath in
            guard let dataSource else {
                fatalError()
            }
            let snapshot = dataSource.snapshot()
            let view = strategy.supplementaryView(for: collectionView, elementKind: elementKind, at: indexPath, snapshot: snapshot)
            return view
        }

        // Set the final layout
        let layout = strategy.makeLayout(dataSource: dataSource)
        self.collectionViewLayout = layout
    }
}


// MARK: - CollectionViewDataSource propertyWrapper

@propertyWrapper
struct CollectionViewDataSource<SectionIdentifier: Hashable, ItemValue: Hashable> {

    // MARK: Type

    final class Storage {

        private(set) var dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>!

        fileprivate func initialize(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>.CellProvider) -> UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue> {
            self.dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: cellProvider)
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

