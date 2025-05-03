import UIKit


@available(iOS 14, *)
public extension UICollectionViewListCell {

    static func template<Value>(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        configuration: @escaping (UICollectionViewListCell, Value) -> Void
    ) -> Cell<Value> {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return Cell(
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                configuration(cell, value)
                return cell
            },
            layoutItemHandlerProvider: Cell<Any>.makeLayoutItemHandlerProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}
