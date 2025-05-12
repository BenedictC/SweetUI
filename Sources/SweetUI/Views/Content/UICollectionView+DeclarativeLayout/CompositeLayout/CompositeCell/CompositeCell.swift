import UIKit


public struct CompositeCell<ItemIdentifier>: GroupItem {

    // MARK: Types

    public typealias CellRegister = (UICollectionView) -> Void
    public typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    public typealias LayoutGroupItemProvider = (_ size: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem
    public typealias Predicate = (_ indexPath: IndexPath, _ item: ItemIdentifier) -> Bool // Used by factories


    // MARK: Properties

    let cellRegistrar: CellRegister
    let cellProvider: CellProvider
    let layoutGroupItemProvider: LayoutGroupItemProvider


    // MARK: Instance life cycle

    public init(
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellProvider: @escaping CellProvider,
        layoutGroupItemProvider: @escaping LayoutGroupItemProvider = Self.makeLayoutGroupItemProvider()
    ) {
        self.cellRegistrar = cellRegistrar
        self.cellProvider = cellProvider
        self.layoutGroupItemProvider = layoutGroupItemProvider
    }


    // MARK: Default values

    public static func makeLayoutGroupItemProvider(
        size preferredSize: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil
    ) -> LayoutGroupItemProvider {
        return { defaultSize, environment in
            let size = preferredSize ?? defaultSize
            let item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: [])
            if let edgeSpacing {
                item.edgeSpacing = edgeSpacing
            }
            if let contentInsets {
                item.contentInsets = contentInsets
            }
            return item
        }
    }


    // MARK: GroupItem

    public func registerReusableViews(in collectionView: UICollectionView) {
        cellRegistrar(collectionView)
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        layoutGroupItemProvider(defaultSize, environment)
    }

    public func makeCell(for collectionView: UICollectionView, itemIdentifier: ItemIdentifier, at indexPath: IndexPath) -> UICollectionViewCell? {
        cellProvider(collectionView, indexPath, itemIdentifier)
    }

    public func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, itemIdentifier: ItemIdentifier, at indexPath: IndexPath) -> UICollectionReusableView? {
        nil
    }
}
