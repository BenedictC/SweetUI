import Foundation
import UIKit


// MARK: - ListLayout

@available(iOS 14, *)
public typealias ListLayout = ListLayoutCollectionViewStrategy

@available(iOS 14, *)
public struct ListLayoutCollectionViewStrategy<SectionIdentifier: Hashable, ItemValue: Hashable>: CollectionViewLayoutStrategy {

    let appearance: UICollectionLayoutListConfiguration.Appearance
    let components: ListLayoutComponents<SectionIdentifier, ItemValue>
    public let behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemValue>
    private let emptyFooter = Footer<SectionIdentifier> { _ in
        UIView()
            .frame(height: 0)
    }

    internal init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        components: ListLayoutComponents<SectionIdentifier, ItemValue>,
        behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemValue>
    ) {
        self.appearance = appearance
        self.components = components
        self.behaviors = behaviors
    }

    public func registerReusableViews(in collectionView: UICollectionView, layout: UICollectionViewLayout) {
        components.header?.registerSupplementaryView(in: collectionView)
        components.footer?.registerSupplementaryView(in: collectionView)
        for section in components.sections {
            section.registerViews(in: collectionView)
        }
        emptyFooter.registerSupplementaryView(in: collectionView)
    }

    public func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: appearance)
        let firstHeader = components.sections[0].components.header
        switch firstHeader {
        case .collapsable:
            listConfiguration.headerMode = .firstItemInSection
        case .standard:
            listConfiguration.headerMode = .supplementary
        case .none:
            break
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
        var builder = listConfiguration as any LayoutConfigurationBuilder
        components.configuration?.builder(&builder)
        listConfiguration = builder as! UICollectionLayoutListConfiguration
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

    public func cell(for collectionView: UICollectionView, itemValue: ItemValue, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.section(for: sectionIdentifier)
        let shouldUseHeaderCell = indexPath.item == 0
        if shouldUseHeaderCell,
           case .collapsable(let headerCell) = section.components.header {
            return headerCell.makeCell(with: itemValue, for: collectionView, at: indexPath)
        }
        return section.components.cell.makeCell(with: itemValue, for: collectionView, at: indexPath)
    }

    public func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionReusableView {
        if  let header = components.header,
            elementKind == header.elementKind {
            return header.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: ())
        }
        if  let footer = components.footer,
            elementKind == footer.elementKind {
            return footer.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: ())
        }
        guard let sectionIdentifier = dataSource.sectionIdentifier(forSectionAtIndex: indexPath.section) else {
            preconditionFailure("Invalid section index")
        }
        let section = section(for: sectionIdentifier)
        let view = section.makeSupplementaryView(for: collectionView, elementKind: elementKind, at: indexPath, sectionIdentifier: sectionIdentifier)
        return view ?? emptySupplementaryView(in: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }

    func emptySupplementaryView(in collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        emptyFooter.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }
}

@available(iOS 14, *)
public struct ListLayoutComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {

    let configuration: LayoutConfiguration?
    let header: LayoutHeader?
    let footer: LayoutFooter?
    let sections: [AnyListSection<SectionIdentifier, ItemValue>]    
}


// MARK: - LayoutConfiguration

@available(iOS 14, *)
public protocol LayoutConfigurationBuilder {
    var showsSeparators: Bool { get set }
    @available(iOS 14.5, *)
    var separatorConfiguration: UIListSeparatorConfiguration { get set }
    @available(iOS 14.5, *)
    var itemSeparatorHandler: UICollectionLayoutListConfiguration.ItemSeparatorHandler?  { get set }
    var backgroundColor: UIColor? { get set }
    var leadingSwipeActionsConfigurationProvider: UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider? { get set }
    var trailingSwipeActionsConfigurationProvider: UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider? { get set }
    @available(iOS 15, *)
    var headerTopPadding: CGFloat? { get set }
}

@available(iOS 14, *)
extension UICollectionLayoutListConfiguration: LayoutConfigurationBuilder { }

@available(iOS 14, *)
public struct LayoutConfiguration {

    let builder: (inout LayoutConfigurationBuilder) -> Void

    @available(iOS 14, *)
    public init(builder: @escaping (inout LayoutConfigurationBuilder) -> Void) {
        self.builder = builder
    }
}


// MARK: - ListSection

public protocol ListSection {
    associatedtype SectionIdentifier: Hashable
    associatedtype ItemValue: Hashable

    var predicate: ((SectionIdentifier) -> Bool)? { get }
    var components: ListSectionComponents<SectionIdentifier, ItemValue> { get }
}

public struct AnyListSection<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    public let predicate: ((SectionIdentifier) -> Bool)?
    public let components: ListSectionComponents<SectionIdentifier, ItemValue>

    func registerViews(in collectionView: UICollectionView) {
        components.cell.registerCellClass(in: collectionView)
        switch components.header {
        case .standard(let header):
            header.registerSupplementaryView(in: collectionView)
        case .collapsable(let cell):
            cell.registerCellClass(in: collectionView)
        case .none:
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

public struct ListSectionComponents<SectionIdentifier: Hashable, ItemValue: Hashable> {
    public enum HeaderKind {
        case none
        case standard(Header<SectionIdentifier>)
        case collapsable(Cell<ItemValue>)
    }
    let cell: Cell<ItemValue>
    let header: HeaderKind
    let footer: Footer<SectionIdentifier>?
}


// MARK: - ListSectionWithoutHeader

public struct ListSectionWithoutHeader<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    // MARK: Properties

    public let predicate: ((SectionIdentifier) -> Bool)?
    public let components: ListSectionComponents<SectionIdentifier, ItemValue>
}


// MARK: - ListSectionWithStandardHeader

public struct ListSectionWithStandardHeader<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    // MARK: Properties

    public let predicate: ((SectionIdentifier) -> Bool)?
    public let components: ListSectionComponents<SectionIdentifier, ItemValue>
}


// MARK: - ListSectionWithCollapsableHeader

public struct ListSectionWithCollapsableHeader<SectionIdentifier: Hashable, ItemValue: Hashable>: ListSection {

    // MARK: Properties

    public let predicate: ((SectionIdentifier) -> Bool)?
    public let components: ListSectionComponents<SectionIdentifier, ItemValue>
}


// MARK: - Cell

@available(iOS 14, *)
public extension Cell {

    init(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        configuration: @escaping (UICollectionViewListCell, ItemValue) -> Void)
    {
        let reuseIdentifier = UniqueIdentifier("\(UICollectionViewListCell.self)").value
        self.init(
            size: size,
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
