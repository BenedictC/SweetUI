import UIKit


public struct ListLayoutCellContent<ItemIdentifier> {

    public typealias CellRegister = (UICollectionView) -> Void
    public typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifier) -> (UICollectionViewCell?)

    fileprivate let cellRegistrar: CellRegister
    fileprivate let cellProvider: CellProvider

    public init(
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellProvider: @escaping CellProvider
    ) {
        self.cellRegistrar = cellRegistrar
        self.cellProvider = cellProvider
    }

    func registerCellClass(in collectionView: UICollectionView) {
        cellRegistrar(collectionView)
    }

    func makeCell(with value: ItemIdentifier, for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell? {
        cellProvider(collectionView, indexPath, value)
    }
}


// MARK: - Init

public extension _Cell where Content == ListLayoutCellContent<ItemIdentifier> {

    init(
        cellRegistrar: @escaping ListLayoutCellContent<ItemIdentifier>.CellRegister,
        cellProvider: @escaping ListLayoutCellContent<ItemIdentifier>.CellProvider
    ) {
        self.content = ListLayoutCellContent(
            cellRegistrar: cellRegistrar,
            cellProvider: cellProvider
        )
    }
}


// MARK: - Item mapping

public extension _Cell where Content == ListLayoutCellContent<ItemIdentifier> {

    static func mapItem<Value>(
        _ transform: @escaping (ItemIdentifier) -> Value?,
        cell: () -> _Cell<ListLayoutCellContent<Value>, Value>
    ) -> Self {
        let inner = cell()
        return _Cell(
            cellRegistrar: inner.content.cellRegistrar,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                guard let value = transform(itemIdentifier) else {
                    return nil
                }
                return inner.content.cellProvider(collectionView, indexPath, value)
            }
        )
    }
}
