import UIKit


public protocol BoundarySupplement<Value> {

    associatedtype Value

    typealias SupplementRegistrar = (UICollectionView) -> Void
    typealias SupplementProvider = (UICollectionView, IndexPath, Value) -> UICollectionReusableView?

    func registerReusableViews(in collectionView: UICollectionView)
    func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionReusableView?
}


//public protocol InitializableBoundarySupplement: BoundarySupplement {
//
//    static var defaultBoundarySupplementaryItem: NSCollectionLayoutBoundarySupplementaryItem { get }
//
//    var supplementRegistrar: SupplementRegistrar { get }
//    var boundarySupplementaryItem: NSCollectionLayoutBoundarySupplementaryItem { get }
//    var supplementProvider: SupplementProvider { get }
//
//
//    init(
//        supplementRegistrar: @escaping SupplementRegistrar,
//        boundarySupplementaryItem: NSCollectionLayoutBoundarySupplementaryItem,
//        supplementProvider: @escaping SupplementProvider
//    )
//}
//
//public extension InitializableBoundarySupplement {
//
//    static var elementKind: String {
//        UniqueIdentifier("\(self)").value
//    }
//
//    func registerReusableViews(in collectionView: UICollectionView) {
//        supplementRegistrar(collectionView)
//    }
//
//    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
//        boundarySupplementaryItem
//    }
//
//    func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionReusableView? {
//        guard elementKind == boundarySupplementaryItem.elementKind else { return nil }
//        return supplementProvider(collectionView, indexPath, value)
//    }
//}
//
//
////// MARK: - ???
////
////public extension InitializableBoundarySupplement {
////
////    init<View: ReusableViewConfigurable>(
////        viewClass: View.Type,
////        width: NSCollectionLayoutDimension? = nil,
////        height: NSCollectionLayoutDimension? = nil,
////        alignment: NSRectAlignment? = nil,
////        absoluteOffset: CGPoint = .zero,
////        extendsBoundary: Bool? = nil,
////        pinToVisibleBounds: Bool? = nil
////    ) where View.Value == SectionIdentifier {
////        fatalError()
////
////        let elementKind = Self.elementKind
////        let reuseIdentifier = UniqueIdentifier(elementKind).value
////        let viewRegistrar = { (collectionView: UICollectionView) in
////            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
////        }
////        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView in
////            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! View
////            view.configure(withValue: sectionIdentifier)
////            return view
////        }
////        self.init(
////            width: width,
////            height: height,
////            alignment: alignment,
////            absoluteOffset: absoluteOffset,
////            extendsBoundary: extendsBoundary,
////            pinToVisibleBounds: pinToVisibleBounds,
////            viewRegistrar: viewRegistrar,
////            viewFactory: viewFactory)
//    }
//}
//
//
////// MARK: - ???
////
////@available(iOS 14, *)
////public extension InitializableBoundSupplement {
////
////    init(
////        width: NSCollectionLayoutDimension? = nil,
////        height: NSCollectionLayoutDimension? = nil,
////        alignment: NSRectAlignment? = nil?
////        absoluteOffset: CGPoint = .zero,
////        extendsBoundary: Bool? = nil,
////        pinToVisibleBounds: Bool? = nil,
////        configuration: @escaping (UICollectionViewListCell, SectionIdentifier) -> Void)
////    {
////        let viewClass = UICollectionViewListCell.self
////        let elementKind = Self.elementKind
////        let reuseIdentifier = UniqueIdentifier(elementKind).value
////        let viewRegistrar = { (collectionView: UICollectionView) in
////            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
////        }
////        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView in
////            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
////            configuration(view, sectionIdentifier)
////            return view
////        }
////        self.init(
////            width: width,
////            height: height,
////            alignment: alignment,
////            absoluteOffset: absoluteOffset,
////            extendsBoundary: extendsBoundary,
////            pinToVisibleBounds: pinToVisibleBounds,
////            viewRegistrar: viewRegistrar,
////            viewFactory: viewFactory)
////    }
////}
//
//
//// MARK: - ???
//
//public extension InitializableBoundarySupplement {
//
//    init(
//        width: NSCollectionLayoutDimension? = nil,
//        height: NSCollectionLayoutDimension? = nil,
//        containerAnchor: NSCollectionLayoutAnchor? = nil,
//        itemAnchor: NSCollectionLayoutAnchor? = nil,
//        absoluteOffset: CGPoint = .zero,
//        extendsBoundary: Bool? = nil,
//        pinToVisibleBounds: Bool? = nil,
//        bindingOptions: BindingOptions = .default,
//        body bodyProvider: @escaping (OneWayBinding<Value>) -> UIView
//    ) {
//        typealias CellType = ValuePublishingCell<Value>
//        let elementKind = Self.elementKind
//        let reuseIdentifier = elementKind
//
//        let defaultItem = Self.defaultBoundarySupplementaryItem
//        let boundarySupplementaryItem = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: NSCollectionLayoutSize(
//                widthDimension: width ?? defaultItem.layoutSize.widthDimension,
//                heightDimension: height ?? defaultItem.layoutSize.heightDimension
//            ),
//            elementKind: defaultItem.elementKind,
//            containerAnchor: containerAnchor ?? defaultItem.containerAnchor,
//            itemAnchor: itemAnchor ?? defaultItem.itemAnchor,
//            absoluteOffset: absoluteOffset
//        )
//
//        self.init(
//            supplementRegistrar: { collectionView in
//                collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
//            },
//            boundarySupplementaryItem: boundarySupplementaryItem,
//            supplementProvider: { collectionView, indexPath, value in
//                let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
//                view.initialize(bindingOptions: bindingOptions, bodyProvider: { _, publisher in bodyProvider(publisher) })
//                view.configure(withValue: value)
//                return view
//            }
//        )
//    }
//}
//
//
////// MARK: - ???
////
////public extension InitializableBoundSupplement where SectionIdentifier == Void {
////
////    init(
////        width: NSCollectionLayoutDimension = .fractionalWidth(1),
////        height: NSCollectionLayoutDimension = .estimated(44),
////        alignment: NSRectAlignment = Self.defaultAlignment,
////        absoluteOffset: CGPoint = .zero,
////        extendsBoundary: Bool? = nil,
////        pinToVisibleBounds: Bool? = nil,
////        body bodyProvider: @escaping () -> UIView
////    ) {
////        let viewClass = ValuePublishingCell<Void>.self
////        let elementKind = Self.elementKind
////        let reuseIdentifier = UniqueIdentifier(elementKind).value
////        let viewRegistrar = { (collectionView: UICollectionView) in
////            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
////        }
////        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: Void) -> UICollectionReusableView in
////            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<Void>
////            view.initialize(bindingOptions: .default, bodyProvider: { _, _ in bodyProvider() })
////            view.configure(using: sectionIdentifier)
////            return view
////        }
////        self.init(
////            width: width,
////            height: height,
////            alignment: alignment,
////            absoluteOffset: absoluteOffset,
////            extendsBoundary: extendsBoundary,
////            pinToVisibleBounds: pinToVisibleBounds,
////            viewRegistrar: viewRegistrar,
////            viewFactory: viewFactory)
////    }
////}
