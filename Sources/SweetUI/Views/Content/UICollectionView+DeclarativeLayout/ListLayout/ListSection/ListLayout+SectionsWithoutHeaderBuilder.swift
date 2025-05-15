import UIKit


// MARK: - Layout

@available(iOS 14, *)
public extension ListLayout {

    typealias ListSectionWithoutHeader = ListSection<SectionIdentifier, ItemIdentifier, Void>

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil,
        header: LayoutHeader? = nil,
        footer: LayoutFooter? = nil,
        @ArrayBuilder<ListSectionWithoutHeader>
        sectionsWithoutHeader sections: () -> [ListSectionWithoutHeader]
    ) {
        let components = ListLayoutComponents(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: sections().map { $0.eraseToAnyListSection() }
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )
        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil,
        header: LayoutHeader? = nil,
        footer: LayoutFooter? = nil,
        @ArrayBuilder<ListCell<ItemIdentifier>>
        cells: () -> [ListCell<ItemIdentifier>]
    ) {
        let section = ListSectionWithoutHeader(cells: cells()).eraseToAnyListSection()
        let components = ListLayoutComponents(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: [section]
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )
        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}


// MARK: - ListSection

@available(iOS 14, *)
public extension ListSection where HeaderType == Void {

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        footer: SectionFooter<SectionIdentifier>? = nil,
        cells: [ListCell<ItemIdentifier>]
    ) {
        self = Self(
            predicate: predicate,
            header: .none,
            cells: cells,
            footer: footer
        )
    }

    init(
        identifier: SectionIdentifier,
        footer: SectionFooter<SectionIdentifier>? = nil,
        cells: [ListCell<ItemIdentifier>]
    ) {
        self = Self(
            predicate: { $0 == identifier },
            header: .none,
            cells: cells,
            footer: footer
        )
    }
}

@available(iOS 14, *)
public extension ListSection where HeaderType == Void {

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        footer: SectionFooter<SectionIdentifier>,
        @ArrayBuilder<ListCell<ItemIdentifier>>
        cells: () -> [ListCell<ItemIdentifier>]
    ) {
        self = Self(
            predicate: predicate,
            header: .none,
            cells: cells(),
            footer: footer
        )
    }

    init(
        identifier: SectionIdentifier,
        footer: SectionFooter<SectionIdentifier>,
        @ArrayBuilder<ListCell<ItemIdentifier>>
        cells: () -> [ListCell<ItemIdentifier>]
    ) {
        self = Self(
            predicate: { $0 == identifier },
            header: .none,
            cells: cells(),
            footer: footer
        )
    }

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        @ArrayBuilder<ListCell<ItemIdentifier>>
        cells: () -> [ListCell<ItemIdentifier>]
    ) {
        self = Self(
            predicate: predicate,
            header: .none,
            cells: cells(),
            footer: nil
        )
    }

    init(
        identifier: SectionIdentifier,
        @ArrayBuilder<ListCell<ItemIdentifier>>
        cells: () -> [ListCell<ItemIdentifier>]
    ) {
        self = Self(
            predicate: { $0 == identifier },
            header: .none,
            cells: cells(),
            footer: nil
        )
    }
}
