import UIKit


// MARK: - ConfigurableCollectionViewCell

public extension ConfigurableCollectionViewCell {

    static func template(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil
    ) -> Cell<Value> {
        let reuseIdentifier = UniqueIdentifier("\(Self.self)").value
        return Cell(
            cellRegistrar: { collectionView in
                collectionView.register(Self.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! Self
                cell.configure(with: value)
                return cell
            },
            layoutItemHandlerProvider: Cell<Any>.makeLayoutItemHandlerProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}


// MARK: - Replace contents of cell.content

public extension UICollectionViewCell {

    private class ContentCell<Content: UIView>: UICollectionViewCell {
        var content: Content?
        let cancellableStorage = CancellableStorage()
    }

    static func template<Value, Content: UIView>(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        dropsDuplicateValues: Bool = true,
        content contentBuilder: @escaping (_ cell: UICollectionViewCell, _ existing: Content?, _ value: Value) -> Content
    ) -> Cell<Value> {
        typealias CellType = ContentCell<Content>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return Cell(
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
            },
            layoutItemHandlerProvider: Cell<Any>.makeLayoutItemHandlerProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}


// MARK: - Published Value

public extension UICollectionViewCell {

    static func template<Value>(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        bindingOptions: BindingOptions = .default,
        body bodyProvider: @escaping (UICollectionViewCell, OneWayBinding<Value>) -> UIView
    ) -> Cell<Value> {
        typealias CellType = ValuePublishingCell<Value>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return Cell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.initialize(bindingOptions: bindingOptions, bodyProvider: bodyProvider)
                cell.configure(using: value)
                return cell
            },
            layoutItemHandlerProvider: Cell<Any>.makeLayoutItemHandlerProvider(size: size, edgeSpacing: edgeSpacing, contentInsets: contentInsets)
        )
    }
}
