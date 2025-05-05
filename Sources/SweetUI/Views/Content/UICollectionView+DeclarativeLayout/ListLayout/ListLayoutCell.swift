import UIKit


public struct ListLayoutCell<ItemIdentifier> {

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


// MARK: - Item mapping

public extension Cell {
    
    static func mapItem<Value>(
        _ transform: @escaping (ItemIdentifier) -> Value?,
        cell: () -> ListLayoutCell<Value>
    ) -> ListLayoutCell<ItemIdentifier> {
        let inner = cell()
        return ListLayoutCell(
            cellRegistrar: inner.cellRegistrar,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                guard let value = transform(itemIdentifier) else {
                    return nil
                }
                return inner.cellProvider(collectionView, indexPath, value)
            }
        )
    }
}
