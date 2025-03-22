import Foundation
import UIKit
import Combine


@available(iOS 14, *)
public extension UICollectionView {

    convenience init<SectionIdentifier: Hashable, ItemValue: Hashable, Strategy: CollectionViewLayoutStrategy>(
        snapshot snapshotCoordinator:  CollectionViewSnapshot<SectionIdentifier, ItemValue>.Coordinator,
        delegate: UICollectionViewDelegate? = nil,
        layout strategyBuilder: () -> Strategy
    ) where Strategy.SectionIdentifier == SectionIdentifier,
            Strategy.ItemValue == ItemValue
    {
        // Init with placeholder layout
        self.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())

        let strategy = strategyBuilder()

        // Configure dataSource (the dataSource is stored by the snapshotCoordinator)
        let dataSource = snapshotCoordinator.register(
            collectionView: self,
            cellProvider: { collectionView, indexPath, itemValue in
                let dataSource = collectionView.dataSource as! UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>
                guard let sectionIdentifier = dataSource.sectionIdentifier(forSectionAtIndex: indexPath.section) else {
                    preconditionFailure("Invalid section index")
                }
                let cell = strategy.cell(for: collectionView, itemValue: itemValue, in: sectionIdentifier, at: indexPath)
                return cell
            }
        )
        guard let dataSource else {
            log.error("Failed to register collectionView with snapshot coordinator. CollectionView will not function.")
            return
        }
        dataSource.supplementaryViewProvider = { [weak dataSource] collectionView, elementKind, indexPath in
            guard let dataSource else {
                fatalError()
            }
            let view = strategy.supplementaryView(for: collectionView, elementKind: elementKind, at: indexPath, dataSource: dataSource)
            return view
        }
        dataSource.indexElementsProvider = strategy.behaviors.indexElementsProvider
        if let reorderHandlers = strategy.behaviors.reorderHandlers {
            dataSource.reorderingHandlers = reorderHandlers
        }
        if let sectionSnapshotHandlers = strategy.behaviors.sectionSnapshotHandlers {
            dataSource.sectionSnapshotHandlers = sectionSnapshotHandlers
        }

        // Configure and store the final layout
        let layout = strategy.makeLayout(dataSource: dataSource)
        strategy.registerReusableViews(in: self, layout: layout)
        self.collectionViewLayout = layout

        // Configure delegate
        self.delegate = delegate
    }
}
