public struct LayoutHeader {

    // MARK: Types

    public typealias SupplementRegistrar = (UICollectionView) -> Void
    public typealias SupplementProvider = (String, UICollectionView, IndexPath, Void) -> UICollectionReusableView?


    // MARK: Properties

    let elementKind = UniqueIdentifier("LayoutHeader").value
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
            alignment: .top,
            absoluteOffset: .zero
        )
        return layoutItem
    }

    public func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, indexPath: IndexPath, value: Void) -> UICollectionReusableView? {
        guard elementKind == self.elementKind else { return nil }
        return supplementProvider(elementKind, collectionView, indexPath, value)
    }

    public func asBoundarySupplement() -> BoundarySupplement<Void> {
        return BoundarySupplement(
            supplementRegistrar: registerReusableViews(in:),
            layoutBoundarySupplementaryItemProvider: makeLayoutBoundarySupplementaryItem,
            supplementProvider: makeSupplementaryView(ofKind:for:indexPath:value:)
        )
    }
}


// MARK: - Static

public extension LayoutHeader {

    init<Content: UIView>(
        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping () -> Content
    ) {
        typealias CellType = ContentCell<Content>
        let elementKind = self.elementKind
        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
        self.supplementRegistrar = { collectionView in
            collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.supplementProvider = { _, collectionView, indexPath, sectionIdentifier in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
            if !cell.hasContent {
                cell.replaceContent { _, content in
                    contentBuilder()
                }
            }
            return cell
        }
    }
}
