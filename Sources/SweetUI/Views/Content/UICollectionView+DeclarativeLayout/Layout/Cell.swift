import UIKit


public struct Cell<ItemIdentifier> {

    public typealias CellRegister = (UICollectionView) -> Void
    public typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    public typealias LayoutItemHandlerProvider = (_ size: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem

    private let cellRegistrar: CellRegister
    private let cellProvider: CellProvider
    private let layoutItemHandlerProvider: LayoutItemHandlerProvider

    public init(
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellProvider: @escaping CellProvider,
        layoutItemHandlerProvider: @escaping LayoutItemHandlerProvider = makeLayoutItemHandlerProvider()
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
}


// MARK: - LayoutItemProvider factory

public extension Cell {

    static func makeLayoutItemHandlerProvider(
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


// MARK: - Value mapping

public extension Cell {

    static func mapItem<Value>(
        _ transform: @escaping (ItemIdentifier) -> Value?,
        cell: () -> Cell<Value>
    ) -> Self {
        let inner = cell()
        return Cell(
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
