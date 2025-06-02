import UIKit


@available(iOS 15, *)
public extension ListCell {

    static func withListCell(
        configuration: @escaping (UICollectionViewListCell, ItemIdentifier) -> Void
    ) -> ListCell<ItemIdentifier> {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return ListCell(
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                configuration(cell, value)
                return cell
            }
        )
    }
}


@available(iOS 16, *)
public extension ListCell {

    static func withContentConfiguration(
        _ contentConfiguration: @escaping (inout UIListContentConfiguration, inout UIBackgroundConfiguration?, ItemIdentifier) -> Void
    ) -> ListCell<ItemIdentifier> {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return ListCell(
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
