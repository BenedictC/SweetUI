import UIKit


// MARK: - Layout

@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        header: LayoutHeader? = nil,
        @ArrayBuilder<Section<ListSectionWithStandardHeader<SectionIdentifier, ItemIdentifier>, SectionIdentifier, ItemIdentifier, LayoutHeader>>
        sectionsWithStandardHeader sections: () -> [Section<ListSectionWithStandardHeader<SectionIdentifier, ItemIdentifier>, SectionIdentifier, ItemIdentifier, LayoutHeader>],
        footer: LayoutFooter? = nil,
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil
    ) {
        let anySections = sections().map {
            AnyListSection<SectionIdentifier, ItemIdentifier>(predicate: $0.content.predicate, components: $0.content.components)
        }
        let components = ListLayoutComponents<SectionIdentifier, ItemIdentifier>(
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


// MARK: - Section

@available(iOS 14, *)
public extension Section where Content == ListSectionWithStandardHeader<SectionIdentifier, ItemIdentifier> {

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        header: Header<SectionIdentifier>,
        cells: [Cell<ItemIdentifier>],
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.content = ListSectionWithStandardHeader<SectionIdentifier, ItemIdentifier>(
            predicate: predicate,
            components: ListSectionComponents(
                cells: cells,
                header: .standard(header),
                footer: footer
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: Header<SectionIdentifier>,
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
public extension Section where Content == ListSectionWithStandardHeader<SectionIdentifier, ItemIdentifier> {

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        header: () -> Header<SectionIdentifier>,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>],
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.content = ListSectionWithStandardHeader<SectionIdentifier, ItemIdentifier>(
            predicate: predicate,
            components: ListSectionComponents(
                cells: cells(),
                header: .standard(header()),
                footer: footer()
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: () -> Header<SectionIdentifier>,
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
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        header: () -> Header<SectionIdentifier>,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>]
    ) {
        self.content = ListSectionWithStandardHeader<SectionIdentifier, ItemIdentifier>(
            predicate: predicate,
            components: ListSectionComponents(
                cells: cells(),
                header: .standard(header()),
                footer: nil
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: () -> Header<SectionIdentifier>,
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
