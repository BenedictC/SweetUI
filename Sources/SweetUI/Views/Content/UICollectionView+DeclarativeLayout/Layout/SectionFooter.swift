import UIKit


public struct SectionFooter<SectionIdentifier> {

    // MARK: Types

    public typealias SupplementRegistrar = (UICollectionView) -> Void
    public typealias SupplementProvider = (String, UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView?


    // MARK: Properties

    let elementKind = UICollectionView.elementKindSectionFooter
    private let supplementRegistrar: SupplementRegistrar
    private let supplementProvider: SupplementProvider


    // MARK: Instance life cycle

    init(
        supplementRegistrar: @escaping SupplementRegistrar,
        supplementProvider: @escaping SupplementProvider
    ) {
        self.supplementRegistrar = supplementRegistrar
        self.supplementProvider = supplementProvider
    }


    // MARK:  BoundarySupplement

    public func registerReusableViews(in collectionView: UICollectionView) {
        supplementRegistrar(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        let layoutItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: elementKind,
            alignment: .bottom,
            absoluteOffset: .zero
        )
        return layoutItem
    }

    public func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, indexPath: IndexPath, value: SectionIdentifier) -> UICollectionReusableView? {
        guard elementKind == self.elementKind else { return nil }
        return supplementProvider(elementKind, collectionView, indexPath, value)
    }

    public func asBoundarySupplement() -> BoundarySupplement<SectionIdentifier> {
        return BoundarySupplement(
            supplementRegistrar: registerReusableViews(in:),
            layoutBoundarySupplementaryItemProvider: makeLayoutBoundarySupplementaryItem,
            supplementProvider: makeSupplementaryView(ofKind:for:indexPath:value:)
        )
    }
}


// MARK: - Static

public extension SectionFooter {

    init(
        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping (UICollectionViewCell, OneWayBinding<SectionIdentifier>) -> UIView
    ) {
        typealias CellType = ValuePublishingCell<SectionIdentifier>
        let elementKind = self.elementKind
        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
        self.supplementRegistrar = { collectionView in
            collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.supplementProvider = { elementKind, collectionView, indexPath, sectionIdentifier in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
            cell.initialize(bindingOptions: bindingOptions, bodyProvider: contentBuilder)
            cell.configure(withValue: sectionIdentifier)
            return cell
        }
    }
}
