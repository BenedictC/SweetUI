import UIKit


// MARK: - Layout

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


// MARK: - Section

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

    init(
        identifier: SectionIdentifier,
        header: Header<SectionIdentifier>,
        cell: Cell<ItemValue>,
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.init(
            predicate: { $0 == identifier },
            header: header,
            cell: cell,
            footer: footer
        )
    }
}


@available(iOS 14, *)
public extension Section where Content == ListSectionWithStandardHeader<SectionIdentifier, ItemValue> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        header: () -> Header<SectionIdentifier>,
        cell: () -> Cell<ItemValue>,
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.content = ListSectionWithStandardHeader<SectionIdentifier, ItemValue>(
            predicate: predicate,
            components: ListSectionComponents(
                cell: cell(),
                header: .standard(header()),
                footer: footer()
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: () -> Header<SectionIdentifier>,
        cell: () -> Cell<ItemValue>,
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.init(
            predicate: { $0 == identifier },
            header: header(),
            cell: cell(),
            footer: footer()
        )
    }

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        header: () -> Header<SectionIdentifier>,
        cell: () -> Cell<ItemValue>
    ) {
        self.content = ListSectionWithStandardHeader<SectionIdentifier, ItemValue>(
            predicate: predicate,
            components: ListSectionComponents(
                cell: cell(),
                header: .standard(header()),
                footer: nil
            )
        )
    }

    init(
        identifier: SectionIdentifier,
        header: () -> Header<SectionIdentifier>,
        cell: () -> Cell<ItemValue>
    ) {
        self.init(
            predicate: { $0 == identifier },
            header: header(),
            cell: cell(),
            footer: nil
        )
    }
}
