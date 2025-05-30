import UIKit


// MARK: - Replace contents of cell.content

public extension CompositeCell {

    static func withContent<Content: UIView>(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        dropsDuplicateValues: Bool = true,
        content contentBuilder: @escaping (_ cell: UICollectionViewCell, _ existing: Content?, _ value: ItemIdentifier) -> Content
    ) -> CompositeCell {
        typealias CellType = ContentCell<Content>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return CompositeCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.replaceContent { cell, content in
                    contentBuilder(cell, content, value)
                }
                return cell
            },
            layoutGroupItemProvider: Self.makeLayoutGroupItemProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}


// MARK: - Published Value

public extension CompositeCell {

    static func withContent(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        body bodyProvider: @escaping (UICollectionViewCell, any CurrentValuePublisher<ItemIdentifier, Never>) -> UIView
    ) -> CompositeCell {
        typealias CellType = ValuePublishingCell<ItemIdentifier>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return CompositeCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.initialize(bodyProvider: bodyProvider)
                cell.configure(withValue: value)
                return cell
            },
            layoutGroupItemProvider: Self.makeLayoutGroupItemProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}
