import UIKit


// MARK: - Layout

@available(iOS 14, *)
public extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        header: LayoutHeader? = nil,
        @ArrayBuilder<Section<ListSectionWithoutHeader<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, Void>>
        sectionsWithoutHeader sections: () -> [Section<ListSectionWithoutHeader<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, Void>],
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


// MARK: - Section

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

    init(
        identifier: SectionIdentifier,
        cell: Cell<ItemValue>,
        footer: Footer<SectionIdentifier>? = nil
    ) {
        self.init(
            predicate: { $0 == identifier },
            cell: cell,
            footer: footer
        )
    }
}

@available(iOS 14, *)
public extension Section where Content == ListSectionWithoutHeader<SectionIdentifier, ItemValue> {

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        cell: () -> Cell<ItemValue>,
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.init(
            predicate: predicate,
            cell: cell(),
            footer: footer()
        )
    }

    init(
        identifier: SectionIdentifier,
        cell: () -> Cell<ItemValue>,
        footer: () -> Footer<SectionIdentifier>
    ) {
        self.init(
            predicate: { $0 == identifier },
            cell: cell(),
            footer: footer()
        )
    }

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        cell: () -> Cell<ItemValue>
    ) {
        self.init(
            predicate: predicate,
            cell: cell(),
            footer: nil
        )
    }

    init(
        identifier: SectionIdentifier,
        cell: () -> Cell<ItemValue>
    ) {
        self.init(
            predicate: { $0 == identifier },
            cell: cell(),
            footer: nil
        )
    }
}
