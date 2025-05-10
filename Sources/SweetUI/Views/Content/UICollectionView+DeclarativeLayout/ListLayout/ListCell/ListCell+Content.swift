import UIKit


// MARK: - Replace contents of cell.content

public extension ListCell {

    private class ContentCell<Content: UIView>: UICollectionViewCell {
        var content: Content?
        let cancellableStorage = CancellableStorage()
    }

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
                let stale = cell.content
                let fresh = cell.cancellableStorage.storeCancellables {
                    contentBuilder(cell, stale, value)
                }
                if stale != fresh {
                    stale?.removeFromSuperview()
                    cell.content = fresh
                    let container = cell.contentView
                    container.addSubview(fresh)
                    fresh.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        fresh.topAnchor.constraint(equalTo: container.topAnchor),
                        fresh.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                        fresh.bottomAnchor.constraint(equalTo: container.bottomAnchor).priority(.almostRequired),
                        fresh.trailingAnchor.constraint(equalTo: container.trailingAnchor).priority(.almostRequired),
                    ])
                }
                return cell
            }
        )
    }
}


// MARK: - Published Value

public extension ListCell {

    static func withContent(
        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping (UICollectionViewCell, OneWayBinding<ItemIdentifier>) -> UIView
    ) -> ListCell<ItemIdentifier> {
        typealias CellType = ValuePublishingCell<ItemIdentifier>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return ListCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.initialize(bindingOptions: bindingOptions, bodyProvider: contentBuilder)
                cell.configure(withValue: value)
                return cell
            }
        )
    }
}
