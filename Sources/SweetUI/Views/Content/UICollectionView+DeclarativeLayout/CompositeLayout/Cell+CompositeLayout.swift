import UIKit


// MARK: - Cell

extension Cell: GroupItem {

    public init(
        size: NSCollectionLayoutSize?,
        edgeSpacing: NSCollectionLayoutEdgeSpacing?,
        contentInsets: NSDirectionalEdgeInsets?,
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellFactory: @escaping (UICollectionView, IndexPath, ItemValue) -> UICollectionViewCell)
    {
        let makeLayoutItemHandler = { (defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem in
            let size = size ?? defaultSize
            let item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: [])
            if let edgeSpacing {
                item.edgeSpacing = edgeSpacing
            }
            if let contentInsets {
                item.contentInsets = contentInsets
            }
            return item
        }
        self.init(cellFactory: cellFactory, cellRegistrar: cellRegistrar, makeLayoutItemHandler: makeLayoutItemHandler)
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        // Cells are registered separately
        []
    }

    public func cellsForRegistration() -> [Cell<ItemValue>] { [self] }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        self.makeLayoutItem(defaultSize: defaultSize, environment: environment)
    }
}
