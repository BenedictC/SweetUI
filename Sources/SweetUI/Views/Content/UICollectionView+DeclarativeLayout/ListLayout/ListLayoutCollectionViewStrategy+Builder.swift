import UIKit


@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    private init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration,
        header: LayoutHeader?,
        sections: [AnyListSection<SectionIdentifier, ItemValue>],
        footer: LayoutFooter?,
        behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemValue>
    ) {
        let components = ListLayoutComponents(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: sections
        )
        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}


@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        header: LayoutHeader? = nil,
        sectionsWithoutHeader sections: [Section<ListSectionWithoutHeader<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, Void>],
        footer: LayoutFooter? = nil,
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemValue>? = nil
    ) {
        let components = ListLayoutComponents(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: sections.map { AnyListSection<SectionIdentifier, ItemValue>(predicate: nil, components: $0.content.components) }
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )
        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}


@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        header: LayoutHeader? = nil,
        @ArrayBuilder<Section<ListSectionWithStandardHeader<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, LayoutHeader>>
        sectionsWithStandardHeader sections: () -> [Section<ListSectionWithStandardHeader<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, LayoutHeader>],
        footer: LayoutFooter? = nil,
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemValue>? = nil
    ) {
        let anySections = sections().map {
            AnyListSection<SectionIdentifier, ItemValue>(predicate: $0.content.predicate, components: $0.content.components)
        }
        let components = ListLayoutComponents<SectionIdentifier, ItemValue>(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: anySections
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )

        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}


@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        header: LayoutHeader? = nil,
        @ArrayBuilder<Section<ListSectionWithCollapsableHeader<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, LayoutHeader>>
        sectionsWithCollapsableHeader sections: () -> [Section<ListSectionWithCollapsableHeader<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, LayoutHeader>],
        footer: LayoutFooter? = nil,
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemValue>? = nil
    ) {
        let components = ListLayoutComponents(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: sections().map { AnyListSection<SectionIdentifier, ItemValue>(predicate: nil, components: $0.content.components) }
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )

        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}


@available(iOS 14, *)
public extension Section where Content == ListSectionWithoutHeader<SectionIdentifier, ItemValue> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        cell: Cell<ItemValue>,
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.content = ListSectionWithoutHeader<SectionIdentifier, ItemValue>(
            predicate: predicate,
            components: ListSectionComponents(
                cell: cell,
                header: .none,
                footer: footer
            )
        )
    }
}


@available(iOS 14, *)
public extension Section where Content == ListSectionWithStandardHeader<SectionIdentifier, ItemValue> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        header: Header<SectionIdentifier>,
        cell: Cell<ItemValue>,
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.content = ListSectionWithStandardHeader<SectionIdentifier, ItemValue>(
            predicate: predicate,
            components: ListSectionComponents(
                cell: cell,
                header: .standard(header),
                footer: footer
            )
        )
    }
}


@available(iOS 14, *)
public extension Section where Content == ListSectionWithCollapsableHeader<SectionIdentifier, ItemValue> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        header: Cell<ItemValue>,
        cell: Cell<ItemValue>,
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.content = ListSectionWithCollapsableHeader<SectionIdentifier, ItemValue>(
            predicate: predicate,
            components: ListSectionComponents(
                cell: cell,
                header: .collapsable(header),
                footer: footer
            )
        )
    }
}
