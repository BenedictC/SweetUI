// MARK: - Section/CompositeSection

@available(iOS 14, *)
public extension Section where Content == CompositeSection<SectionIdentifier, ItemValue>, HeaderType == Void {

    // with non-trailing closure (core)
    init<G: Group>(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        interGroupSpacing: CGFloat? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?? = nil,
        background: Background? = nil,
        sectionSupplementariesByElementKind: [String: AnyBoundarySupplementaryComponent<SectionIdentifier>] = [:],
        itemSupplementaryTemplateByElementKind: [String: ItemSupplementaryTemplate<ItemValue>] = [:],
        group: G
    ) where G.ItemValue == ItemValue
    {
        let content = CompositeSection(
            predicate: predicate,
            components: SectionComponents<SectionIdentifier, ItemValue>(
                group: AnyGroup(
                    allCellsHandler: group.cellsForRegistration,
                    itemSupplementaryTemplatesHandler: group.itemSupplementaryTemplates,
                    makeLayoutGroupHandler: group.makeLayoutGroup
                ),
                background: background,
                sectionSupplementariesByElementKind: sectionSupplementariesByElementKind,
                itemSupplementaryTemplateByElementKind: itemSupplementaryTemplateByElementKind
            ),
            orthogonalScrollingBehavior: orthogonalScrollingBehavior,
            interGroupSpacing: interGroupSpacing,
            contentInsets: contentInsets,
            contentInsetsReference: contentInsetsReference,
            supplementaryContentInsetsReference: supplementaryContentInsetsReference,
            visibleItemsInvalidationHandler: visibleItemsInvalidationHandler
        )
        self = Section(content: content)
    }

    // with trailing closure
    init<G: Group>(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        interGroupSpacing: CGFloat? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?? = nil,
        background: Background? = nil,
        sectionSupplementariesByElementKind: [String: AnyBoundarySupplementaryComponent<SectionIdentifier>] = [:],
        itemSupplementaryTemplateByElementKind: [String: ItemSupplementaryTemplate<ItemValue>] = [:],
        group groupBuilder: () -> G
    ) where G.ItemValue == ItemValue
    {
        self.init(
            predicate: predicate,
            orthogonalScrollingBehavior: orthogonalScrollingBehavior,
            interGroupSpacing: interGroupSpacing,
            contentInsets: contentInsets,
            contentInsetsReference: contentInsetsReference,
            supplementaryContentInsetsReference: supplementaryContentInsetsReference,
            visibleItemsInvalidationHandler: visibleItemsInvalidationHandler,
            background: background,
            sectionSupplementariesByElementKind: sectionSupplementariesByElementKind,
            itemSupplementaryTemplateByElementKind: itemSupplementaryTemplateByElementKind,
            group: groupBuilder()
        )
    }
}


// MARK: with identifier

@available(iOS 14, *)
public extension Section where Content == CompositeSection<SectionIdentifier, ItemValue>, HeaderType == Void {

    // with non-trailing closure
    init<G: Group>(
        identifier: SectionIdentifier,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        interGroupSpacing: CGFloat? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?? = nil,
        background: Background? = nil,
        sectionSupplementariesByElementKind: [String: AnyBoundarySupplementaryComponent<SectionIdentifier>] = [:],
        itemSupplementaryTemplateByElementKind: [String: ItemSupplementaryTemplate<ItemValue>] = [:],
        group: G
    ) where G.ItemValue == ItemValue
    {
        self.init(
            predicate: { $0 == identifier },
            orthogonalScrollingBehavior: orthogonalScrollingBehavior,
            interGroupSpacing: interGroupSpacing,
            contentInsets: contentInsets,
            contentInsetsReference: contentInsetsReference,
            supplementaryContentInsetsReference: supplementaryContentInsetsReference,
            visibleItemsInvalidationHandler: visibleItemsInvalidationHandler,
            background: background,
            sectionSupplementariesByElementKind: sectionSupplementariesByElementKind,
            itemSupplementaryTemplateByElementKind: itemSupplementaryTemplateByElementKind,
            group: group
        )
    }

    // with trailing closure
    init<G: Group>(
        identifier: SectionIdentifier,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        interGroupSpacing: CGFloat? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?? = nil,
        background: Background? = nil,
        sectionSupplementariesByElementKind: [String: AnyBoundarySupplementaryComponent<SectionIdentifier>] = [:],
        itemSupplementaryTemplateByElementKind: [String: ItemSupplementaryTemplate<ItemValue>] = [:],
        group groupBuilder: () -> G
    ) where G.ItemValue == ItemValue
    {
        self.init(
            predicate: { $0 == identifier },
            orthogonalScrollingBehavior: orthogonalScrollingBehavior,
            interGroupSpacing: interGroupSpacing,
            contentInsets: contentInsets,
            contentInsetsReference: contentInsetsReference,
            supplementaryContentInsetsReference: supplementaryContentInsetsReference,
            visibleItemsInvalidationHandler: visibleItemsInvalidationHandler,
            background: background,
            sectionSupplementariesByElementKind: sectionSupplementariesByElementKind,
            itemSupplementaryTemplateByElementKind: itemSupplementaryTemplateByElementKind,
            group: groupBuilder()
        )
    }
}
