import UIKit
import Combine


// MARK: - SupplementaryComponent

public extension Group {

    func supplementaries(@SupplementaryComponentsBuilder<ItemValue> _ supplementsBuilder: () -> [Supplement<ItemValue>]) -> SupplementedGroup<ItemValue> {
        let supplements = supplementsBuilder()
        return SupplementedGroup(
            group: self,
            supplements: supplements
        )
    }
}


public struct SupplementedGroup<ItemValue: Hashable>: Group {

    let group: AnyGroup<ItemValue>
    let supplements: [Supplement<ItemValue>]

    init<G: Group>(group: G, supplements: [Supplement<ItemValue>]) where G.ItemValue == ItemValue {
        self.group = AnyGroup(group: group)
        self.supplements = supplements
    }

    public func allCells() -> [Cell<ItemValue>] {
        fatalError()
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        fatalError()
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        fatalError()
    }
}


public extension Cell {

    func supplementaries(@SupplementaryComponentsBuilder<ItemValue> _ componentsBuilder: () -> [Supplement<ItemValue>]) -> SupplementedGroupItem<ItemValue> {
        let supplements = componentsBuilder()
        return SupplementedGroupItem(cell: self, supplements: supplements)
    }
}


public struct SupplementedGroupItem<ItemValue: Hashable>: GroupItem {

    let cell: Cell<ItemValue>
    let supplements: [Supplement<ItemValue>]

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        cell.itemSupplementaryTemplates() + supplements
            .map { $0.itemSupplementaryTemplates() }
            .reduce([], +)
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem {
        let initial = cell.makeLayoutItem(defaultSize: defaultSize)
        let supplementaryItems = supplements.map { $0.makeLayoutSupplementaryItem(defaultSize: defaultSize) }
        let revised = NSCollectionLayoutItem(layoutSize: initial.layoutSize, supplementaryItems: supplementaryItems)
        revised.edgeSpacing = initial.edgeSpacing
        revised.contentInsets = initial.contentInsets
        return revised
    }

    public func allCells() -> [Cell<ItemValue>] {
        return cell.allCells()
    }
}



@resultBuilder
public struct SupplementaryComponentsBuilder<ItemValue: Hashable> {

    public static func buildBlock(_ components: Supplement<ItemValue>...) -> [Supplement<ItemValue>] {
     return components
    }
}


public struct Supplement<ItemValue: Hashable> {

    let elementKind: String
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, ItemValue) -> UICollectionReusableView
    let layoutItemFactory: (NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem

    internal init(
        elementKind: String,
        viewRegistrar: @escaping (UICollectionView) -> Void,
        viewFactory: @escaping (UICollectionView, IndexPath, ItemValue) -> UICollectionReusableView,
        layoutItemFactory: @escaping (NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem)
    {
        self.elementKind = elementKind
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
        self.layoutItemFactory = layoutItemFactory
    }

    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        [
            ItemSupplementaryTemplate(
            elementKind: elementKind,
            registerItemSupplementaryViewHandler: viewRegistrar,
            makeItemSupplementaryViewHandler: viewFactory)
        ]
    }

    func makeLayoutSupplementaryItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem {
        layoutItemFactory(defaultSize)
    }
}


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
        self.viewFactory = { collectionView, indexPath, itemValue in
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
        configuration: @escaping (UICollectionViewListCell, ItemValue) -> Void)
    {
        let viewClass = UICollectionViewListCell.self
        let elementKind = optionalElementKind ?? UniqueIdentifier("SupplementaryView").value
        let reuseIdentifier = UniqueIdentifier(elementKind).value

        self.elementKind = elementKind
        self.viewRegistrar = { collectionView in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, itemValue in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
            configuration(cell, itemValue)
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
        body bodyFactory: @escaping (AnyPublisher<ItemValue, Never>) -> UIView)
    {
        let viewClass = ValuePublishingCell<ItemValue>.self
        let elementKind = optionalElementKind ?? UniqueIdentifier("SupplementaryView").value
        let reuseIdentifier = UniqueIdentifier(elementKind).value

        self.elementKind = elementKind
        self.viewRegistrar = { collectionView in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, itemValue in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<ItemValue>
            view.bodyFactory = bodyFactory
            view.configure(using: itemValue)
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
