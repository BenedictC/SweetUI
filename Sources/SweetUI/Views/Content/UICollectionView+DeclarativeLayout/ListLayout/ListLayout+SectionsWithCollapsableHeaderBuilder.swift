import UIKit


// MARK: - Layout

@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        header: LayoutHeader? = nil,
        @ArrayBuilder<Section<ListSectionWithCollapsableHeader<SectionIdentifier, ItemIdentifier>, SectionIdentifier, ItemIdentifier, LayoutHeader>>
        sectionsWithCollapsableHeader sections: () -> [Section<ListSectionWithCollapsableHeader<SectionIdentifier, ItemIdentifier>, SectionIdentifier, ItemIdentifier, LayoutHeader>],
        footer: LayoutFooter? = nil,
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil
    ) {
        let components = ListLayoutComponents(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: sections().map { AnyListSection<SectionIdentifier, ItemIdentifier>(predicate: nil, components: $0.content.components) }
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )

        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}


// MARK: - Section

@available(iOS 14, *)
public extension Section where Content == ListSectionWithCollapsableHeader<SectionIdentifier, ItemIdentifier> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        header: Cell<ItemIdentifier>,
        cells: [Cell<ItemIdentifier>],
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.content = ListSectionWithCollapsableHeader<SectionIdentifier, ItemIdentifier>(
            predicate: predicate,
            components: ListSectionComponents(
                cells: cells,
                header: .collapsable(header),
                footer: footer
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: Cell<ItemIdentifier>,
        cells: [Cell<ItemIdentifier>],
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.init(
            predicate: { $0 == identifier },
            header: header,
            cells: cells,
            footer: footer
        )
    }
}


@available(iOS 14, *)
public extension Section where Content == ListSectionWithCollapsableHeader<SectionIdentifier, ItemIdentifier> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        header: () -> Cell<ItemIdentifier>,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>],
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.content = ListSectionWithCollapsableHeader<SectionIdentifier, ItemIdentifier>(
            predicate: predicate,
            components: ListSectionComponents(
                cells: cells(),
                header: .collapsable(header()),
                footer: footer()
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: () -> Cell<ItemIdentifier>,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>],
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.init(
            predicate: { $0 == identifier },
            header: header(),
            cells: cells(),
            footer: footer()
        )
    }

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        header: () -> Cell<ItemIdentifier>,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>]
    ) {
        self.content = ListSectionWithCollapsableHeader<SectionIdentifier, ItemIdentifier>(
            predicate: predicate,
            components: ListSectionComponents(
                cells: cells(),
                header: .collapsable(header()),
                footer: nil
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: () -> Cell<ItemIdentifier>,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>]
    ) {
        self.init(
            predicate: { $0 == identifier },
            header: header(),
            cells: cells(),
            footer: nil
        )
    }
}
