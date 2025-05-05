import UIKit


public protocol GroupItem<ItemIdentifier> {

    associatedtype ItemIdentifier

    func cellsForRegistration() -> [CompositeLayoutCell<ItemIdentifier>]
    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>]
    func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem
}


public struct SupplementedGroupItem<ItemIdentifier>: GroupItem {

    let cell: CompositeLayoutCell<ItemIdentifier>
    let supplements: [Supplement<ItemIdentifier>]

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        cell.itemSupplementaryTemplates() + supplements
            .map { $0.itemSupplementaryTemplates() }
            .reduce([], +)
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        let initial = cell.makeLayoutItem(defaultSize: defaultSize, environment: environment)
        let supplementaryItems = supplements.map { $0.makeLayoutSupplementaryItem(defaultSize: defaultSize) }
        let revised = NSCollectionLayoutItem(layoutSize: initial.layoutSize, supplementaryItems: supplementaryItems)
        revised.edgeSpacing = initial.edgeSpacing
        revised.contentInsets = initial.contentInsets
        return revised
    }

    public func cellsForRegistration() -> [CompositeLayoutCell<ItemIdentifier>] {
        return cell.cellsForRegistration()
    }
}
