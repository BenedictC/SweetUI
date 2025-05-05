import UIKit


@available(iOS 14, *)
public extension UICollectionViewListCell {

    static func provider<Value>(
        cellConfiguration: @escaping (UICollectionViewListCell, Value) -> Void
    ) -> ListLayoutCell<Value> {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return ListLayoutCell(
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                cellConfiguration(cell, value)
                return cell
            }
        )
    }
}


@available(iOS 16, *)
public extension UICollectionViewListCell {

    static func provider<Value>(
        contentConfiguration: @escaping (inout UIListContentConfiguration, inout UIBackgroundConfiguration?, Value) -> Void
    ) -> ListLayoutCell<Value> {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return ListLayoutCell(
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
            }
        )
    }
}
