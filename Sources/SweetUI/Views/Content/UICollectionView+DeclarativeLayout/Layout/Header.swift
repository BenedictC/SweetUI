import UIKit


public struct Header<SectionIdentifier>: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    public static var elementKind: String { UICollectionView.elementKindSectionHeader }
    public static var defaultAlignment: NSRectAlignment { .topLeading }
    public var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    public init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }


    public func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset)
        if let extendsBoundary {
            layoutItem.extendsBoundary = extendsBoundary
        }
        if let pinToVisibleBounds {
            layoutItem.pinToVisibleBounds = pinToVisibleBounds
        }
        return layoutItem
    }

    public func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}
