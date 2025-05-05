import UIKit


public struct CompositeLayoutCell<ItemIdentifier> {

    public typealias CellRegister = (UICollectionView) -> Void
    public typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    public typealias LayoutItemHandlerProvider = (_ size: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem

    fileprivate let cellRegistrar: CellRegister
    fileprivate let cellProvider: CellProvider
    fileprivate let layoutItemHandlerProvider: LayoutItemHandlerProvider

    public init(
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellProvider: @escaping CellProvider,
        layoutItemHandlerProvider: @escaping LayoutItemHandlerProvider = Self.makeLayoutItemHandlerProvider()
    ) {
        self.cellRegistrar = cellRegistrar
        self.cellProvider = cellProvider
        self.layoutItemHandlerProvider = layoutItemHandlerProvider
    }

    func registerCellClass(in collectionView: UICollectionView) {
        cellRegistrar(collectionView)
    }

    func makeCell(with value: ItemIdentifier, for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell? {
        cellProvider(collectionView, indexPath, value)
    }

    func makeLayoutItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        layoutItemHandlerProvider(defaultSize, environment)
    }


    public static func makeLayoutItemHandlerProvider(
        size preferredSize: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil
    ) -> LayoutItemHandlerProvider {
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
}


// MARK: - Item mapping

public extension Cell {

    static func mapItem<Value>(
        _ transform: @escaping (ItemIdentifier) -> Value?,
        cell: () -> CompositeLayoutCell<Value>
    ) -> CompositeLayoutCell<ItemIdentifier> {
        let inner = cell()
        return CompositeLayoutCell(
            cellRegistrar: inner.cellRegistrar,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                guard let value = transform(itemIdentifier) else {
                    return nil
                }
                return inner.cellProvider(collectionView, indexPath, value)
            },
            layoutItemHandlerProvider: inner.layoutItemHandlerProvider
        )
    }
}
