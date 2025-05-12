import UIKit


public struct BoundarySupplement<Value> {

    // MARK: Types

    public typealias SupplementRegistrar = (UICollectionView) -> Void
    public typealias LayoutBoundarySupplementaryItemProvider = () -> NSCollectionLayoutBoundarySupplementaryItem
    public typealias SupplementProvider = (String, UICollectionView, IndexPath, Value) -> UICollectionReusableView?


    // MARK: Properties

    private let supplementRegistrar: SupplementRegistrar
    private let layoutBoundarySupplementaryItemProvider: LayoutBoundarySupplementaryItemProvider
    private let supplementProvider: SupplementProvider


    // MARK: Instance life cycle

    init(
        supplementRegistrar: @escaping SupplementRegistrar,
        layoutBoundarySupplementaryItemProvider: @escaping LayoutBoundarySupplementaryItemProvider,
        supplementProvider: @escaping SupplementProvider
    ) {
        self.supplementRegistrar = supplementRegistrar
        self.layoutBoundarySupplementaryItemProvider = layoutBoundarySupplementaryItemProvider
        self.supplementProvider = supplementProvider
    }


    // MARK: View registration

    func registerReusableViews(in collectionView: UICollectionView) {
        supplementRegistrar(collectionView)
    }


    // MARK: Layout creation

    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        layoutBoundarySupplementaryItemProvider()
    }


    // MARK: View creation

    func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, value: Value, at indexPath: IndexPath) -> UICollectionReusableView? {
        let expected = makeLayoutBoundarySupplementaryItem().elementKind
        guard elementKind == expected else { return nil }
        return supplementProvider(elementKind, collectionView, indexPath, value)
    }
}


// MARK: - Published

public extension BoundarySupplement {

    init(
        size: NSCollectionLayoutSize,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor?,
        extendsBoundary: Bool?,
        pinToVisibleBounds: Bool?,
        zIndex: Int?,

        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping (_ binding: OneWayBinding<Value>) -> UIView
    ) {
        typealias CellType = ValuePublishingCell<Value>
        let elementKind = UniqueIdentifier("\(Self.self) elementKind").value
        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
        self.init(
            supplementRegistrar: { collectionView in
                collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
            },
            layoutBoundarySupplementaryItemProvider: {
                let item = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: size,
                    elementKind: elementKind,
                    containerAnchor: containerAnchor,
                    itemAnchor: itemAnchor ?? containerAnchor
                )
                extendsBoundary.flatMap { item.extendsBoundary = $0 }
                pinToVisibleBounds.flatMap { item.pinToVisibleBounds = $0 }
                zIndex.flatMap { item.zIndex = $0 }
                return item
            },
            supplementProvider: { _, collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.initialize(bindingOptions: bindingOptions, bodyProvider: { contentBuilder($1) })
                cell.configure(withValue: value)
                return cell
            }
        )
    }
}


// MARK: - Content

public extension BoundarySupplement {

    init<Content: UIView>(
        size: NSCollectionLayoutSize,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor?,
        extendsBoundary: Bool?,
        pinToVisibleBounds: Bool?,
        zIndex: Int?,

        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping (_ existing: Content?, _ value: Value) -> Content
    ) {
        typealias CellType = ContentCell<Content>
        let elementKind = UniqueIdentifier("\(Self.self) elementKind").value
        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
        self.init(
            supplementRegistrar: { collectionView in
                collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
            },
            layoutBoundarySupplementaryItemProvider: {
                let item = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: size,
                    elementKind: elementKind,
                    containerAnchor: containerAnchor,
                    itemAnchor: itemAnchor ?? containerAnchor
                )
                extendsBoundary.flatMap { item.extendsBoundary = $0 }
                pinToVisibleBounds.flatMap { item.pinToVisibleBounds = $0 }
                zIndex.flatMap { item.zIndex = $0 }
                return item
            },
            supplementProvider: { _, collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.replaceContent { _, content in
                    contentBuilder(content, value)
                }
                return cell
            }
        )
    }
}


////// MARK: - AnyBoundarySupplement
////
////public struct AnyBoundarySupplement<Value>: BoundarySupplement {
////
////    let erased: any BoundarySupplement<Value>
////
////    public func registerReusableViews(in collectionView: UICollectionView) {
////        erased.registerReusableViews(in: collectionView)
////    }
////
////    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
////        erased.makeLayoutBoundarySupplementaryItem()
////    }
////
////    public func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionReusableView? {
////        erased.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: value)
////    }
////}
////
////
////public extension BoundarySupplement {
////
////    func eraseToAnyBoundarySupplement() -> AnyBoundarySupplement<Value> {
////        AnyBoundarySupplement(erased: self)
////    }
////}
