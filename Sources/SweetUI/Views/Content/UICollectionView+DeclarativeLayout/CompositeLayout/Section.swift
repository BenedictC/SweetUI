import UIKit


// MARK: - Section

@available(iOS 14, *) 
public struct Section<SectionIdentifier: Hashable, ItemValue: Hashable> {

    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)?
    let components: SectionComponents<SectionIdentifier, ItemValue>

    let orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?
    let interGroupSpacing: CGFloat?
    let contentInsets: NSDirectionalEdgeInsets?
    let contentInsetsReference: UIContentInsetsReference?
    let supplementaryContentInsetsReference: UIContentInsetsReference?
    let visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler??


    // MARK: Instance life cycle

    public init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        interGroupSpacing: CGFloat? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?? = nil,
        @SectionComponentsBuilder<SectionIdentifier, ItemValue> components: () -> SectionComponents<SectionIdentifier, ItemValue>)
    {
        self.predicate = predicate
        self.components = components()

        self.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        self.interGroupSpacing = interGroupSpacing
        self.contentInsets = contentInsets
        self.contentInsetsReference = contentInsetsReference
        self.supplementaryContentInsetsReference = supplementaryContentInsetsReference
        self.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
    }


    // MARK: View registration

    func registerDecorationViews(in layout: UICollectionViewLayout) {
        if let background = components.background {
            background.registerDecorationView(in: layout)
        }
    }

    func registerCellsAndSupplementaryViews(in collectionView: UICollectionView) {
        // Register the cells
        for cell in components.group.cellsForRegistration() {
            cell.registerCellClass(in: collectionView)
        }
        // Section supplementary
        for supplementary in components.sectionSupplementariesByElementKind.values {
            supplementary.registerSupplementaryView(in: collectionView)
        }
        // Item supplementary
        for template in components.itemSupplementaryTemplateByElementKind.values {
            template.registerItemSupplementaryView(in: collectionView)
        }
    }

    func registerItemReusableViews(in collectionView: UICollectionView) {
        // Item supplements
        for template in components.itemSupplementaryTemplateByElementKind.values {
            template.registerItemSupplementaryView(in: collectionView)
        }
    }


    // MARK: Template fetching

    func itemSupplementaryTemplate(for elementKind: String) -> ItemSupplementaryTemplate<ItemValue>? {
        components.itemSupplementaryTemplateByElementKind[elementKind]
    }

    func cellTemplate(forItemIndex index: Int) -> Cell<ItemValue> {
        components.group.cell(forItemIndex: index)
    }


    // MARK: Factory

    func makeCompositionalLayoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let group = components.group.makeLayoutGroup(environment: environment)

        let section = NSCollectionLayoutSection(group: group)
        if let orthogonalScrollingBehavior {
            section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        }
        if let interGroupSpacing {
            section.interGroupSpacing = interGroupSpacing
        }
        if let contentInsets {
            section.contentInsets = contentInsets
        }
        if let contentInsetsReference {
            section.contentInsetsReference = contentInsetsReference
        }
        if #available(iOS 16.0, *) {
            if let supplementaryContentInsetsReference {
                section.supplementaryContentInsetsReference = supplementaryContentInsetsReference
            }
        }
        if let visibleItemsInvalidationHandler {
            section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        }

        let boundarySupplementaryItem = components.sectionSupplementariesByElementKind.values
            .map { $0.makeLayoutBoundarySupplementaryItem() }

        section.boundarySupplementaryItems = boundarySupplementaryItem

        if let background = components.background {
            section.decorationItems = [background.makeLayoutDecorationItem()]
        }

        return section
    }
}

@available(iOS 14, *)
extension Section {

    init(
        identifier: SectionIdentifier,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        interGroupSpacing: CGFloat? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?? = nil,
        @SectionComponentsBuilder<SectionIdentifier, ItemValue> components: () -> SectionComponents<SectionIdentifier, ItemValue>)
    {
        let predicate = { $0 == identifier }
        self.init(
            predicate: predicate,
            orthogonalScrollingBehavior: orthogonalScrollingBehavior,
            interGroupSpacing: interGroupSpacing,
            contentInsets: contentInsets,
            contentInsetsReference: contentInsetsReference,
            supplementaryContentInsetsReference: supplementaryContentInsetsReference,
            visibleItemsInvalidationHandler: visibleItemsInvalidationHandler,
            components: components)
    }
}

public struct ItemSupplementaryTemplate<ItemValue> {
    
    let elementKind: String
    let registerItemSupplementaryViewHandler: (UICollectionView) -> Void
    let makeItemSupplementaryViewHandler: (UICollectionView, IndexPath, ItemValue) -> UICollectionReusableView

    func registerItemSupplementaryView(in collectionView: UICollectionView) {
        registerItemSupplementaryViewHandler(collectionView)
    }

    func makeItemSupplementaryView(in collectionView: UICollectionView, indexPath: IndexPath, itemValue: ItemValue) -> UICollectionReusableView {
        makeItemSupplementaryViewHandler(collectionView, indexPath, itemValue)
    }
}

public struct SectionComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {

    let group: AnyGroup<ItemValue>
    let background: Background?
    let sectionSupplementariesByElementKind: [String: AnyBoundarySupplementaryComponent<SectionIdentifier>]
    let itemSupplementaryTemplateByElementKind: [String: ItemSupplementaryTemplate<ItemValue>]

    public init(group: AnyGroup<ItemValue>, supplementaries: [AnyBoundarySupplementaryComponent<SectionIdentifier>], background: Background?) {
        self.group = group

        var supplementariesByElementKind = [String: AnyBoundarySupplementaryComponent<SectionIdentifier>]()
        // Section supplementaries
        for supplementary in supplementaries {
            supplementariesByElementKind[supplementary.elementKind] = supplementary
        }
        self.sectionSupplementariesByElementKind = supplementariesByElementKind
        self.background = background
        // Item supplementaries
        var itemSupplementaryTemplateByElementKind = [String: ItemSupplementaryTemplate<ItemValue>]()
        for template in group.itemSupplementaryTemplates() {
            itemSupplementaryTemplateByElementKind[template.elementKind] = template
        }
        self.itemSupplementaryTemplateByElementKind = itemSupplementaryTemplateByElementKind
    }
}


@resultBuilder
public struct SectionComponentsBuilder<SectionIdentifier: Hashable, ItemValue: Hashable> {

    public static func buildBlock<G: Group>(_ group: G) -> SectionComponents<SectionIdentifier, ItemValue> where G.ItemValue == ItemValue {
        let anyGroup = AnyGroup(group: group)
        return SectionComponents(group: anyGroup, supplementaries: [], background: nil)
    }

    public static func buildBlock<S: BoundarySupplementaryComponent, G: Group>(_ supplementary: S, _ group: G) -> SectionComponents<SectionIdentifier, ItemValue> where S.SectionIdentifier == SectionIdentifier, G.ItemValue == ItemValue {
        let anySup = AnyBoundarySupplementaryComponent(erased: supplementary)
        let anyGroup = AnyGroup(group: group)
        return SectionComponents(group: anyGroup, supplementaries: [anySup], background: nil)
    }

    public static func buildBlock<H: BoundarySupplementaryComponent, F: BoundarySupplementaryComponent, G: Group>(_ header: H, _ footer: F, _ group: G) -> SectionComponents<SectionIdentifier, ItemValue> where H.SectionIdentifier == SectionIdentifier, F.SectionIdentifier == SectionIdentifier, G.ItemValue == ItemValue {
        let anyHeader = AnyBoundarySupplementaryComponent(erased: header)
        let anyFooter = AnyBoundarySupplementaryComponent(erased: footer)
        let anyGroup = AnyGroup(group: group)
        return SectionComponents(group: anyGroup, supplementaries: [anyHeader, anyFooter], background: nil)
    }

    public static func buildBlock<G: Group>(_ background: Background, _ group: G) -> SectionComponents<SectionIdentifier, ItemValue> where G.ItemValue == ItemValue {
        let anyGroup = AnyGroup(group: group)
        return SectionComponents(group: anyGroup, supplementaries: [], background: background)
    }

    public static func buildBlock<S: BoundarySupplementaryComponent, G: Group>(_ supplementary: S, _ background: Background, _ group: G) -> SectionComponents<SectionIdentifier, ItemValue> where S.SectionIdentifier == SectionIdentifier, G.ItemValue == ItemValue {
        let anySup = AnyBoundarySupplementaryComponent(erased: supplementary)
        let anyGroup = AnyGroup(group: group)
        return SectionComponents(group: anyGroup, supplementaries: [anySup], background: background)
    }

    public static func buildBlock<H: BoundarySupplementaryComponent, F: BoundarySupplementaryComponent, G: Group>(_ header: H, _ footer: F, _ background: Background, _ group: G) -> SectionComponents<SectionIdentifier, ItemValue> where H.SectionIdentifier == SectionIdentifier, F.SectionIdentifier == SectionIdentifier, G.ItemValue == ItemValue {
        let anyHeader = AnyBoundarySupplementaryComponent(erased: header)
        let anyFooter = AnyBoundarySupplementaryComponent(erased: footer)
        let anyGroup = AnyGroup(group: group)
        return SectionComponents(group: anyGroup, supplementaries: [anyHeader, anyFooter], background: background)
    }
}
