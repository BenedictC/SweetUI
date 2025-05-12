import UIKit


@available(iOS 14, *)
public extension CompositeCell {

    static func withListCell (
        predicate: @escaping Predicate = { _, _ in true },
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        cellConfiguration: @escaping (UICollectionViewListCell, ItemIdentifier) -> Void
    ) -> CompositeCell {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return CompositeCell(
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                guard predicate(indexPath, value) else { return nil }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                cellConfiguration(cell, value)
                return cell
            },
            layoutGroupItemProvider: Self.makeLayoutGroupItemProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}


@available(iOS 16, *)
public extension CompositeCell {

    static func withListCell(
        predicate: @escaping Predicate = { _, _ in true },
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentConfiguration: @escaping (inout UIListContentConfiguration, inout UIBackgroundConfiguration?, ItemIdentifier) -> Void
    ) -> CompositeCell {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        return CompositeCell(
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                guard predicate(indexPath, value) else { return nil }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                var content = cell.defaultContentConfiguration()
                var background: UIBackgroundConfiguration? = cell.defaultBackgroundConfiguration()
                contentConfiguration(&content, &background, value)
                cell.contentConfiguration = content
                cell.backgroundConfiguration = background
                return cell
            },
            layoutGroupItemProvider: Self.makeLayoutGroupItemProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}
