import Foundation
import UIKit
import SweetUI


// MARK: - ListLayout

typealias ListLayout = ListLayoutCollectionViewStrategy

struct ListLayoutCollectionViewStrategy<SectionIdentifier: Hashable, ItemValue: Hashable>: CollectionViewStrategy {

    let appearance: UICollectionLayoutListConfiguration.Appearance
    let components: ListLayoutComponents<SectionIdentifier, ItemValue>
    private let emptyFooter = Footer<SectionIdentifier> { _ in
        UIView()
            .frame(height: 0)
    }

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        @ListLayoutComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ListLayoutComponents<SectionIdentifier, ItemValue>)
    {
        self.appearance = appearance
        self.components = components()
    }

    func registerReusableViews(in collectionView: UICollectionView) {
        components.header?.registerSupplementaryView(in: collectionView)
        components.footer?.registerSupplementaryView(in: collectionView)
        for section in components.sections {
            section.registerViews(in: collectionView)
        }
        emptyFooter.registerSupplementaryView(in: collectionView)
    }

    func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: appearance)
        if let firstHeader = components.sections[0].components.header {
            switch firstHeader {
            case .collapsable:
                listConfiguration.headerMode = .firstItemInSection
            case .standard:
                listConfiguration.headerMode = .supplementary
            }
        }
        let hasFooter = components.sections.contains { $0.components.footer != nil }
        if hasFooter {
            listConfiguration.footerMode = .supplementary
        }

        let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        if let header = components.header {
            let headerItem = header.makeLayoutBoundarySupplementaryItem()
            layoutConfiguration.boundarySupplementaryItems += [headerItem]
        }
        if let footer = components.footer {
            let footerItem = footer.makeLayoutBoundarySupplementaryItem()
            layoutConfiguration.boundarySupplementaryItems += [footerItem]
        }

        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        layout.configuration = layoutConfiguration

        return layout
    }

    private func section(for sectionIdentifier: SectionIdentifier) -> AnyListSection<SectionIdentifier, ItemValue> {
        // Check sections with predicates for a match
        if let section = components.sections.first(where: { $0.predicate?(sectionIdentifier) ?? false }) {
            return section
        }
        // Default to first section that matches all sections
        if let section = components.sections.first(where: { $0.predicate == nil }) {
            return section
        }
        preconditionFailure("No sections to represent sectionIdentifier '\(sectionIdentifier)'.")
    }

    func cell(for collectionView: UICollectionView, itemValue: ItemValue, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.section(for: sectionIdentifier)
        let shouldUseHeaderCell = indexPath.item == 0
        if shouldUseHeaderCell,
           case .collapsable(let headerCell) = section.components.header {
            return headerCell.makeCell(with: itemValue, for: collectionView, at: indexPath)
        }
        return section.components.cell.makeCell(with: itemValue, for: collectionView, at: indexPath)
    }

    func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue>) -> UICollectionReusableView {
        if  let header = components.header,
            elementKind == header.elementKind {
            return header.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: ())
        }
        if  let footer = components.footer,
            elementKind == footer.elementKind {
            return footer.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: ())
        }
        let sectionIdentifier = snapshot.sectionIdentifiers[indexPath.section]
        let section = section(for: sectionIdentifier)
        let view = section.makeSupplementaryView(for: collectionView, elementKind: elementKind, at: indexPath, sectionIdentifier: sectionIdentifier)
        return view ?? emptySupplementaryView(in: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }

    func emptySupplementaryView(in collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        emptyFooter.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }
}


struct ListLayoutComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {

    let header: LayoutHeader?
    let footer: LayoutFooter?
    let sections: [AnyListSection<SectionIdentifier, ItemValue>]
}


@resultBuilder
struct ListLayoutComponentsBuilder<SectionIdentifier: Hashable, ItemValue: Hashable> {

    static func buildBlock<Section: ListSection, SectionIdentifier: Hashable, ItemValue: Hashable>(
        _ sections: Section...
    ) -> ListLayoutComponents<SectionIdentifier, ItemValue>
    where Section.SectionIdentifier == SectionIdentifier, Section.ItemValue == ItemValue
    {
        let erasedSections = sections.map { AnyListSection<SectionIdentifier, ItemValue>(predicate: $0.predicate, components: $0.components) }
        return ListLayoutComponents(header: nil, footer: nil, sections: erasedSections)
    }

    static func buildBlock<Section: ListSection, SectionIdentifier: Hashable, ItemValue: Hashable>(
        _ header: LayoutHeader,
        _ sections: Section...
    ) -> ListLayoutComponents<SectionIdentifier, ItemValue>
    where Section.SectionIdentifier == SectionIdentifier, Section.ItemValue == ItemValue
    {
        let erasedSections = sections.map { AnyListSection<SectionIdentifier, ItemValue>(predicate: $0.predicate, components: $0.components) }
        return ListLayoutComponents(header: header, footer: nil, sections: erasedSections)
    }

    static func buildBlock<Section: ListSection, SectionIdentifier: Hashable, ItemValue: Hashable>(
        _ footer: LayoutFooter,
        _ sections: Section...
    ) -> ListLayoutComponents<SectionIdentifier, ItemValue>
    where Section.SectionIdentifier == SectionIdentifier, Section.ItemValue == ItemValue
    {
        "TODO: Figure out how to move the footer to after sections. Tricky because sections is vardic"
        let erasedSections = sections.map { AnyListSection<SectionIdentifier, ItemValue>(predicate: $0.predicate, components: $0.components) }
        return ListLayoutComponents(header: nil, footer: footer, sections: erasedSections)
    }

    static func buildBlock<Section: ListSection, SectionIdentifier: Hashable, ItemValue: Hashable>(
        _ header: LayoutHeader,
        _ footer: LayoutFooter,
        _ sections: Section...
    ) -> ListLayoutComponents<SectionIdentifier, ItemValue>
    where Section.SectionIdentifier == SectionIdentifier, Section.ItemValue == ItemValue
    {
        "TODO: Figure out how to move the footer to after sections. Tricky because sections is vardic"
        let erasedSections = sections.map { AnyListSection<SectionIdentifier, ItemValue>(predicate: $0.predicate, components: $0.components) }
        return ListLayoutComponents(header: header, footer: footer, sections: erasedSections)
    }
}


// MARK: - ListSection

protocol ListSection {
    associatedtype SectionIdentifier: Hashable
    associatedtype ItemValue: Hashable

    var predicate: ((SectionIdentifier) -> Bool)? { get }
    var components: ListSectionComponents<SectionIdentifier, ItemValue> { get }
}

struct AnyListSection<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    let predicate: ((SectionIdentifier) -> Bool)?
    let components: ListSectionComponents<SectionIdentifier, ItemValue>

    func registerViews(in collectionView: UICollectionView) {
        components.cell.registerCellClass(in: collectionView)
        switch components.header {
        case .standard(let header):
            header.registerSupplementaryView(in: collectionView)
        case .collapsable(let cell):
            cell.registerCellClass(in: collectionView)
        case nil:
            break
        }
        components.footer?.registerSupplementaryView(in: collectionView)
    }

    func makeSupplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard case .standard(let header) = components.header else {
                return nil
            }
            return header.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
            
        case UICollectionView.elementKindSectionFooter:
            return components.footer?.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
            
        default:
            return nil
        }
    }
}

struct ListSectionComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {
    enum HeaderKind {
        case standard(Header<SectionIdentifier>)
        case collapsable(Cell<ItemValue>)
    }
    let cell: Cell<ItemValue>
    let header: HeaderKind?
    let footer: Footer<SectionIdentifier>?
}


// MARK: - ListSectionWithoutHeader

struct ListSectionWithoutHeader<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    // MARK: Types

    @resultBuilder
    struct ComponentsBuilder<SectionIdentifier: Hashable, ItemValue: Hashable> {

        static func buildBlock(_ cell: Cell<ItemValue>) -> ListSectionComponents<SectionIdentifier, ItemValue> {
            return ListSectionComponents(cell: cell, header: nil, footer: nil)
        }

        static func buildBlock(_ cell: Cell<ItemValue>, _ footer: Footer<SectionIdentifier>) -> ListSectionComponents<SectionIdentifier, ItemValue> {
            return ListSectionComponents(cell: cell, header: nil, footer: footer)
        }
    }


    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)?
    let components: ListSectionComponents<SectionIdentifier, ItemValue>


    // MARK: Instance life cycle

    init(
        identifier: SectionIdentifier,
        @ComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ListSectionComponents<SectionIdentifier, ItemValue>)
    {
        let predicate = { $0 == identifier }
        self.init(predicate: predicate, components: components)
    }

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        @ComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ListSectionComponents<SectionIdentifier, ItemValue>)
    {
        self.predicate = predicate
        self.components = components()
    }
}


// MARK: - ListSectionWithStandardHeader

struct ListSectionWithStandardHeader<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    // MARK: Types

    @resultBuilder
    struct ComponentsBuilder<SectionIdentifier: Hashable, ItemValue: Hashable> {

        static func buildBlock(_ header: Header<SectionIdentifier>, _ cell: Cell<ItemValue>) -> ListSectionComponents<SectionIdentifier, ItemValue> {
            return ListSectionComponents(cell: cell, header: .standard(header), footer: nil)
        }

        static func buildBlock(_ header: Header<SectionIdentifier>, _ cell: Cell<ItemValue>, _ footer: Footer<SectionIdentifier>) -> ListSectionComponents<SectionIdentifier, ItemValue> {
            return ListSectionComponents(cell: cell, header: .standard(header), footer: footer)
        }
    }


    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)?
    let components: ListSectionComponents<SectionIdentifier, ItemValue>


    // MARK: Instance life cycle

    init(
        identifier: SectionIdentifier,
        @ComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ListSectionComponents<SectionIdentifier, ItemValue>)
    {
        let predicate = { $0 == identifier }
        self.init(predicate: predicate, components: components)
    }

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        @ComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ListSectionComponents<SectionIdentifier, ItemValue>)
    {
        self.predicate = predicate
        self.components = components()
    }
}


// MARK: - ListSectionWithCollapsableHeader

struct ListSectionWithCollapsableHeader<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    // MARK: Types

    @resultBuilder
    struct ComponentsBuilder<SectionIdentifier: Hashable, ItemValue: Hashable> {

        static func buildBlock(_ header: Cell<ItemValue>, _ cell: Cell<ItemValue>) -> ListSectionComponents<SectionIdentifier, ItemValue> {
            return ListSectionComponents(cell: cell, header: .collapsable(header), footer: nil)
        }

        static func buildBlock(_ header: Cell<ItemValue>, _ cell: Cell<ItemValue>, _ footer: Footer<SectionIdentifier>) -> ListSectionComponents<SectionIdentifier, ItemValue> {
            return ListSectionComponents(cell: cell, header: .collapsable(header), footer: footer)
        }
    }


    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)?
    let components: ListSectionComponents<SectionIdentifier, ItemValue>


    // MARK: Instance life cycle

    init(
        identifier: SectionIdentifier,
        @ComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ListSectionComponents<SectionIdentifier, ItemValue>)
    {
        let predicate = { $0 == identifier }
        self.init(predicate: predicate, components: components)
    }

    init(
        predicate: ((SectionIdentifier) -> Bool)? = nil,
        @ComponentsBuilder<SectionIdentifier, ItemValue> components: () -> ListSectionComponents<SectionIdentifier, ItemValue>)
    {
        self.predicate = predicate
        self.components = components()
    }
}


// MARK: - Cell

public extension Cell {

    init(configuration: @escaping (UICollectionViewListCell, ItemValue) -> Void) {
        let reuseIdentifier = "\(UICollectionViewListCell.self) \(UUID())"
        self.init(
            width: .fractionalWidth(1),
            height: .estimated(44),
            edgeSpacing: nil,
            contentInsets: nil,
            cellRegistrar: { collectionView in
                collectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            }, cellFactory: { collectionView, indexPath, itemValue in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
                configuration(cell, itemValue)
                return cell
            })
    }
}
