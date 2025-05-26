import UIKit


// MARK: - Replace contents of cell.content

public extension ListCell {

    static func withContent<Content: UIView>(
        dropsDuplicateValues: Bool = true,
        contentBuilder: @escaping (_ cell: UICollectionViewCell, _ existing: Content?, _ value: ItemIdentifier) -> Content
    ) -> ListCell {
        typealias CellType = ContentCell<Content>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return ListCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.replaceContent { cell, content in
                    contentBuilder(cell, content, value)
                }
                return cell
            }
        )
    }
}


// MARK: - Published Value

public extension ListCell {

    static func withContent(
        contentBuilder: @escaping (UICollectionViewCell, AnyPublisher<ItemIdentifier, Never>) -> UIView
    ) -> ListCell<ItemIdentifier> {
        typealias CellType = ValuePublishingCell<ItemIdentifier>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return ListCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.initialize(bodyProvider: contentBuilder)
                cell.configure(withValue: value)
                return cell
            }
        )
    }
}
