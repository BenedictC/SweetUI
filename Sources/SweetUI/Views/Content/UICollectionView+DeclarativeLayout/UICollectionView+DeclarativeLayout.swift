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
