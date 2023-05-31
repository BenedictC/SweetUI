import Foundation
import UIKit
import SweetUI

/*
 Composable
     + BoundarySupplementary (special cases for Header & Footer)
     - BackgroundDecoration // Only needs to be a UIView. Can we structure the decorationItem so we can use it here too?
     + Section <— Predicate-able
         + BoundarySupplementary (special cases for Header & Footer)
         - BackgroundDecoration // Is this the only permitted decorationItem?
         - Group
             + GroupItem

 GroupItem
 | Cell
     + SupplementaryItems
 | Group // Provides a default size to its children
     + SupplementaryItems
     + GroupItem


 VGroup(size:repetitions:builder: () -> Item)
 VGroup(size:builder: () -> [Item])

 HGroup(size:repetitions:builder: () -> Item)
 HGroup(size:builder: () -> [Item])

 CustomGroup(size:provider)


 protocol GroupItem {
     func layoutItem(defaultSize: Size) -> NSCollectionLayoutItem
 }
 */

// MARK: - ComposableLayout

typealias ComposableLayout = ComposableLayoutCollectionViewStrategy

struct ComposableLayoutCollectionViewStrategy<SectionIdentifier: Hashable, ItemValue: Hashable>: CollectionViewStrategy {

    let components: ComposableLayoutComponents<SectionIdentifier, ItemValue>

    init(@ComposableLayoutComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ComposableLayoutComponents<SectionIdentifier, ItemValue>) {
        self.components = components()
    }

    func registerReusableViews(in collectionView: UICollectionView) {
        for section in components.sections {
            section.registerReusableViews(in: collectionView)
        }
    }

    func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        "TODO: Add header, footer and backhground"
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [weak dataSource] sectionIndex, environment in
                guard let dataSource else {
                    preconditionFailure("DataSource is no longer available.")
                }
                guard let sectionIdentifier = dataSource.sectionIdentifier(for: sectionIndex) else {
                    preconditionFailure("Invalid section index")
                }
                let section = self.section(for: sectionIdentifier)
                return section.makeCompositionalLayoutSection()
            },
            configuration: configuration)
    }

    private func section(for sectionIdentifier: SectionIdentifier) -> Section<SectionIdentifier, ItemValue> {
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

    func cell(for collectionView: UICollectionView, itemValue: ItemValue, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.section(for: sectionIdentifier)
        let cellTemplate = section.cellTemplate(for: itemValue)
        return cellTemplate.makeCell(with: itemValue, for: collectionView, at: indexPath)
    }

    func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue>) -> UICollectionReusableView {
        let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
        let section = self.section(for: sectionIdentifier)
        let template = section.supplementaryTemplate(forElementKind: elementKind)
        return template.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }
}


struct ComposableLayoutComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {

    let header: AnyBoundarySupplementaryComponent<SectionIdentifier>?
    let sections: [Section<SectionIdentifier, ItemValue>]
    let footer: AnyBoundarySupplementaryComponent<SectionIdentifier>?
    let background: Any?
}


@resultBuilder
struct ComposableLayoutComponentsBuilder<SectionIdentifier: Hashable, ItemValue: Hashable> {

    static func buildBlock(_ sections: Section<SectionIdentifier, ItemValue>...) -> ComposableLayoutComponents<SectionIdentifier, ItemValue> {
        return ComposableLayoutComponents(header: nil, sections: sections, footer: nil, background: nil)
    }
}


// MARK: - Section

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

    init(
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

    func registerReusableViews(in collectionView: UICollectionView) {
        components.registerReusableViews(in: collectionView)
    }


    // MARK: Template fetching

    func cellTemplate(for itemValue: ItemValue) -> Cell<ItemValue> {
        components.group.cell
    }

    func supplementaryTemplate(forElementKind elementKind: String) -> AnyBoundarySupplementaryComponent<SectionIdentifier> {
        guard let component = components.supplementariesByElementKind[elementKind] else {
            preconditionFailure()
        }
        return component
    }


    // MARK: Factory

    func makeCompositionalLayoutSection() -> NSCollectionLayoutSection {
        let group = components.group.makeLayoutGroup()

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

        let boundarySupplementaryItem = components.supplementaries
            .map { $0.makeLayoutBoundarySupplementaryItem() }

        section.boundarySupplementaryItems = boundarySupplementaryItem

        "TODO: decorationItems"

        return section
    }
}


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


struct SectionComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {

    let group: Group<ItemValue>
    let supplementariesByElementKind: [String: AnyBoundarySupplementaryComponent<SectionIdentifier>]
    var supplementaries: [AnyBoundarySupplementaryComponent<SectionIdentifier>] { Array(supplementariesByElementKind.values) }

    init(group: Group<ItemValue>, supplementaries: [AnyBoundarySupplementaryComponent<SectionIdentifier>]) {
        self.group = group
        var supplementariesByElementKind = [String: AnyBoundarySupplementaryComponent<SectionIdentifier>]()
        for supplementary in supplementaries {
            supplementariesByElementKind[supplementary.elementKind] = supplementary
        }
        self.supplementariesByElementKind = supplementariesByElementKind
    }

    func registerReusableViews(in collectionView: UICollectionView) {
        group.cell.registerCellClass(in: collectionView)
        for supplementary in supplementariesByElementKind.values {
            supplementary.registerSupplementaryView(in: collectionView)
        }
    }
}


@resultBuilder
struct SectionComponentsBuilder<SectionIdentifier: Hashable, ItemValue: Hashable> {

    static func buildBlock(_ group: Group<ItemValue>) -> SectionComponents<SectionIdentifier, ItemValue> {
        SectionComponents(group: group, supplementaries: [])
    }

    static func buildBlock<H: BoundarySupplementaryComponent>(_ header: H, _ group: Group<ItemValue>) -> SectionComponents<SectionIdentifier, ItemValue> where H.SectionIdentifier == SectionIdentifier {
        let erasedHeader = AnyBoundarySupplementaryComponent(erased: header)
        return SectionComponents(group: group, supplementaries: [erasedHeader])
    }

    static func buildBlock<F: BoundarySupplementaryComponent>(_ group: Group<ItemValue>, _ footer: F) -> SectionComponents<SectionIdentifier, ItemValue> where F.SectionIdentifier == SectionIdentifier {
        let erasedFooter = AnyBoundarySupplementaryComponent(erased: footer)
        return SectionComponents(group: group, supplementaries: [erasedFooter])
    }

    static func buildBlock<H: BoundarySupplementaryComponent, F: BoundarySupplementaryComponent>(_ header: H, _ group: Group<ItemValue>, _ footer: F) -> SectionComponents<SectionIdentifier, ItemValue> where H.SectionIdentifier == SectionIdentifier, F.SectionIdentifier == SectionIdentifier {
        let erasedHeader = AnyBoundarySupplementaryComponent(erased: header)
        let erasedFooter = AnyBoundarySupplementaryComponent(erased: footer)
        return SectionComponents(group: group, supplementaries: [erasedHeader, erasedFooter])
    }
}


// MARK: - Group

public struct Group<ItemValue: Hashable> {

    public enum Axis {
        case horizontal, vertical
    }

    public let axis: Axis
    public let cell: Cell<ItemValue>
    public let width: NSCollectionLayoutDimension
    public let height: NSCollectionLayoutDimension

    public init(
        axis: Axis = .vertical,
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        cell cellBuilder: () -> Cell<ItemValue>)
    {
        self.axis = axis
        self.width = width
        self.height = height
        self.cell = cellBuilder()
    }

    public func makeLayoutGroup() -> NSCollectionLayoutGroup {
        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        "TODO: Figure out what the options are for subitems."
        let subitems = [cell.makeLayoutItem()]
        switch axis {
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: subitems)

        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: subitems)
        }
    }
}
