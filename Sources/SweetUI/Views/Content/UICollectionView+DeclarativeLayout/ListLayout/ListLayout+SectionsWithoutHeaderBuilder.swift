import UIKit


// MARK: - Layout

@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        header: LayoutHeader? = nil,
        @ArrayBuilder<Section<ListSectionWithoutHeader<SectionIdentifier, ItemIdentifier>, SectionIdentifier, ItemIdentifier, Void>>
        sectionsWithoutHeader sections: () -> [Section<ListSectionWithoutHeader<SectionIdentifier, ItemIdentifier>, SectionIdentifier, ItemIdentifier, Void>],
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
public extension Section where Content == ListSectionWithoutHeader<SectionIdentifier, ItemIdentifier> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        cells: [Cell<ItemIdentifier>],
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.content = ListSectionWithoutHeader<SectionIdentifier, ItemIdentifier>(
            predicate: predicate,
            components: ListSectionComponents(
                cells: cells,
                header: .none,
                footer: footer
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        cells: [Cell<ItemIdentifier>],
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.init(
            predicate: { $0 == identifier },
            cells: cells,
            footer: footer
        )
    }
}

@available(iOS 14, *)
public extension Section where Content == ListSectionWithoutHeader<SectionIdentifier, ItemIdentifier> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>],
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.init(
            predicate: predicate,
            cells: cells(),
            footer: footer()
        )
    }

    init(
        identifier: SectionIdentifier,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>],
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.init(
            predicate: { $0 == identifier },
            cells: cells(),
            footer: footer()
        )
    }

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>]
    ) {
        self.init(
            predicate: predicate,
            cells: cells(),
            footer: nil
        )
    }

    init(
        identifier: SectionIdentifier,
        @ArrayBuilder<Cell<ItemIdentifier>> cells: () -> [Cell<ItemIdentifier>]
    ) {
        self.init(
            predicate: { $0 == identifier },
            cells: cells(),
            footer: nil
        )
    }
}
