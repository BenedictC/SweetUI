import UIKit


// MARK: - ReusableViewConfigurable

public extension Supplement {

    init<V: ReusableViewConfigurable>(
        _ viewClass: V.Type,
        elementKind optionalElementKind: String? = nil,
        size: NSCollectionLayoutSize? = nil,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor? = nil
    ) {
        let elementKind = optionalElementKind ?? UniqueIdentifier("SupplementaryView").value
        let reuseIdentifier = UniqueIdentifier(elementKind).value

        self.elementKind = elementKind
        self.viewRegistrar = { collectionView in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, ItemIdentifier in
            collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath)
        }
        self.layoutItemFactory = { defaultSize in
            let size = size ?? defaultSize
            if let itemAnchor {
                return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
            } else {
                return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor)
            }
        }
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
        configuration: @escaping (UICollectionViewListCell, ItemIdentifier) -> Void)
    {
        let viewClass = UICollectionViewListCell.self
        let elementKind = optionalElementKind ?? UniqueIdentifier("SupplementaryView").value
        let reuseIdentifier = UniqueIdentifier(elementKind).value

        self.elementKind = elementKind
        self.viewRegistrar = { collectionView in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, ItemIdentifier in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
            configuration(cell, ItemIdentifier)
            return cell
        }
        self.layoutItemFactory = { defaultSize in
            let size = size ?? defaultSize
            if let itemAnchor {
                return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
            } else {
                return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor)
            }
        }
    }
}


// MARK: - ValuePublishingCell

public extension Supplement {

    init(
        elementKind optionalElementKind: String? = nil,
        size: NSCollectionLayoutSize? = nil,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor? = nil,
        body bodyProvider: @escaping (OneWayBinding<ItemIdentifier>) -> UIView)
    {
        let viewClass = ValuePublishingCell<ItemIdentifier>.self
        let elementKind = optionalElementKind ?? UniqueIdentifier("SupplementaryView").value
        let reuseIdentifier = UniqueIdentifier(elementKind).value

        self.elementKind = elementKind
        self.viewRegistrar = { collectionView in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, itemIdentifier in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<ItemIdentifier>
            view.initialize(bindingOptions: .default, bodyProvider: {_, publisher in bodyProvider(publisher) })
            view.configure(withValue: itemIdentifier)
            return view
        }
        self.layoutItemFactory = { defaultSize in
            let size = size ?? defaultSize
            if let itemAnchor {
                return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
            } else {
                return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor)
            }
        }
    }
}
