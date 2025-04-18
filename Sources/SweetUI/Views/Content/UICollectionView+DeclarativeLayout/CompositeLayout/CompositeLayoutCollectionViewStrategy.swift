import Foundation
import UIKit


// MARK: - CompositeLayout

@available(iOS 14, *)
public typealias CompositeLayout = CompositeLayoutCollectionViewStrategy


@available(iOS 14, *)
public struct CompositeLayoutCollectionViewStrategy<SectionIdentifier: Hashable, ItemValue: Hashable>: CollectionViewLayoutStrategy {

    let components: CompositeLayoutComponents<SectionIdentifier, ItemValue>
    public let behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemValue>

    public func registerReusableViews(in collectionView: UICollectionView, layout: UICollectionViewLayout) {
        // Layout
        components.header?.registerSupplementaryView(in: collectionView)
        components.footer?.registerSupplementaryView(in: collectionView)
        if let background = components.background {
            collectionView.backgroundView = background.view
        }
        // Sections
        for section in components.sections {
            section.registerDecorationViews(in: layout)
            section.registerCellsAndSupplementaryViews(in: collectionView)
        }
    }

    public func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        if let header = components.header {
            let item = header.makeLayoutBoundarySupplementaryItem()
            configuration.boundarySupplementaryItems += [item]
        }
        if let footer = components.footer {
            let item = footer.makeLayoutBoundarySupplementaryItem()
            configuration.boundarySupplementaryItems += [item]
        }
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [weak dataSource] sectionIndex, environment in
                guard let dataSource else {
                    preconditionFailure("DataSource is no longer available.")
                }
                guard let sectionIdentifier = dataSource.sectionIdentifier(forSectionAtIndex: sectionIndex) else {
                    preconditionFailure("Invalid section index")
                }
                let section = self.section(for: sectionIdentifier)
                return section.makeCompositionalLayoutSection(environment: environment)
            },
            configuration: configuration)
    }

    private func section(for sectionIdentifier: SectionIdentifier) -> CompositeSection<SectionIdentifier, ItemValue> {
        // Check sections with predicates for a match
        if let section = components.sections.first(where: { $0.predicate?(sectionIdentifier) ?? false }) {
            return section
        }
        // Default to first section that isn't predicated (should be only one)
        if let section = components.sections.first(where: { $0.predicate == nil }) {
            return section
        }
        preconditionFailure("No sections to represent sectionIdentifier '\(sectionIdentifier)'.")
    }

    public func cell(for collectionView: UICollectionView, itemValue: ItemValue, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.section(for: sectionIdentifier)
        let cell = section.cellTemplate(forItemIndex: indexPath.item)
        return cell.makeCell(with: itemValue, for: collectionView, at: indexPath)
    }

    public func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionReusableView {
        // Is it a layout supplement?
        if let header = components.header,
            elementKind == header.elementKind {
            return header.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: ())
        }
        if let footer = components.footer,
            elementKind == footer.elementKind {
            return footer.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: ())
        }
        guard let sectionIdentifier = dataSource.sectionIdentifier(forSectionAtIndex: indexPath.section) else {
            preconditionFailure("Invalid section index")
        }
        let section = self.section(for: sectionIdentifier)
        // Is it a section supplement?
        if let template = section.components.sectionSupplementariesByElementKind[elementKind] {
            return template.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
        }
        // Must be item supplement
        guard let template = section.itemSupplementaryTemplate(for: elementKind) else {
            preconditionFailure()
        }
        guard let itemValue = dataSource.itemIdentifier(for: indexPath) else {
            preconditionFailure("Invalid indexPath")
        }
        return template.makeItemSupplementaryView(in: collectionView, indexPath: indexPath, itemValue: itemValue)
    }
}


@available(iOS 14, *)
public struct CompositeLayoutComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {

    let header: LayoutHeader?
    let sections: [CompositeSection<SectionIdentifier, ItemValue>]
    let footer: LayoutFooter?
    let background: LayoutBackground?
}


// MARK: - Take 2

@available(iOS 14, *)
public extension CompositeLayoutCollectionViewStrategy {

    init(
        background: LayoutBackground? = nil,
        header: LayoutHeader? = nil,
        footer: LayoutFooter? = nil,
        @ArrayBuilder<Section<CompositeSection<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, Void>> sections: () -> [Section<CompositeSection<SectionIdentifier, ItemValue>, SectionIdentifier, ItemValue, Void>],
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemValue>? = nil
    ) {
        self.components = CompositeLayoutComponents(
            header: header,
            sections: sections().map { $0.content },
            footer: footer,
            background: background
        )
        self.behaviors = .init(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )
    }
}
