import UIKit


@available(iOS 14, *)
public extension UICollectionViewListCell {

    static func provider<Value>(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        cellConfiguration: @escaping (UICollectionViewListCell, Value) -> Void
    ) -> Cell<Value> {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return Cell(
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                cellConfiguration(cell, value)
                return cell
            },
            layoutItemHandlerProvider: Cell<Any>.makeLayoutItemHandlerProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}


@available(iOS 16, *)
public extension UICollectionViewListCell {

    static func provider<Value>(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentConfiguration: @escaping (inout UIListContentConfiguration, inout UIBackgroundConfiguration?, Value) -> Void
    ) -> Cell<Value> {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return Cell(
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                var content = cell.defaultContentConfiguration()
                var background: UIBackgroundConfiguration? = cell.defaultBackgroundConfiguration()
                contentConfiguration(&content, &background, value)
                cell.contentConfiguration = content
                cell.backgroundConfiguration = background
                return cell
            },
            layoutItemHandlerProvider: Cell<Any>.makeLayoutItemHandlerProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}
