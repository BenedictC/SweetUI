import UIKit


// MARK: - ReusableViewConfigurable

public extension Supplement {

    init<V: ReusableViewConfigurable>(
        _ viewClass: V.Type,
        size: NSCollectionLayoutSize? = nil,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor? = nil
    ) {
        let elementKind = UniqueIdentifier("SupplementaryView").value
        let reuseIdentifier = elementKind
        self.init(
            elementKind: elementKind,
            supplementRegistrar: { collectionView in
                collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
            },
            layoutSupplementaryItemProvider: { defaultSize in
                let size = size ?? defaultSize
                if let itemAnchor {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
                } else {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor)
                }
            },
            supplementProvider: { eKind, collectionView, indexPath, ItemIdentifier in
                guard elementKind == eKind else { return nil }
                return collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath)
            }
        )
    }
}


// MARK: - UICollectionViewListCell

@available(iOS 14, *)
public extension Supplement {

    init(
        elementKind optionalElementKind: String? = nil,
        size: NSCollectionLayoutSize? = nil,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor? = nil,
        configuration: @escaping (UICollectionViewListCell, Value) -> Void)
    {
        let viewClass = UICollectionViewListCell.self
        let elementKind = optionalElementKind ?? UniqueIdentifier("SupplementaryView").value
        let reuseIdentifier = UniqueIdentifier(elementKind).value

        self.init(
            elementKind: elementKind,
            supplementRegistrar: { collectionView in
                collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
            },
            layoutSupplementaryItemProvider: { defaultSize in
                let size = size ?? defaultSize
                if let itemAnchor {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
                } else {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor)
                }
            },
            supplementProvider: { eKind, collectionView, indexPath, ItemIdentifier in
                guard eKind == elementKind else { return nil }
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                configuration(cell, ItemIdentifier)
                return cell
            }
        )
    }
}


// MARK: - ValuePublishingCell

public extension Supplement {

    init(
        size: NSCollectionLayoutSize? = nil,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor? = nil,
        body bodyProvider: @escaping (any CurrentValuePublisher<Value, Never>) -> UIView)
    {
        let viewClass = ValuePublishingCell<Value>.self
        let elementKind = UniqueIdentifier("SupplementaryView").value

        self.init(
            elementKind: elementKind,
            supplementRegistrar: { collectionView in
                collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: elementKind)
            },
            layoutSupplementaryItemProvider: { defaultSize in
                let size = size ?? defaultSize
                if let itemAnchor {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
                } else {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor)
                }
            },
            supplementProvider: { eKind, collectionView, indexPath, itemIdentifier in
                guard elementKind == eKind else { return nil }
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: elementKind, for: indexPath) as! ValuePublishingCell<Value>
                view.initialize(bodyProvider: {_, publisher in bodyProvider(publisher) })
                view.configure(withValue: itemIdentifier)
                return view
            }
        )
    }
}
