import Foundation
import UIKit


// MARK: - ListLayout

@available(iOS 14, *)
public struct ListLayout<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: CollectionViewLayoutStrategy {

    let appearance: UICollectionLayoutListConfiguration.Appearance
    let components: ListLayoutComponents<SectionIdentifier, ItemIdentifier>
    public let behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemIdentifier>
    private let emptyFooter = Footer<SectionIdentifier> { _ in
        UIView()
            .frame(height: 0)
    }

    internal init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        components: ListLayoutComponents<SectionIdentifier, ItemIdentifier>,
        behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemIdentifier>
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

    public func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionViewLayout {
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: appearance)
        let firstHeader = components.sections[0].header
        switch firstHeader {
        case .collapsable:
            listConfiguration.headerMode = .firstItemInSection
        case .standard:
            listConfiguration.headerMode = .supplementary
        case .none:
            break
        }
        let hasFooter = components.sections.contains { $0.footer != nil }
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
        var configurationParameters: LayoutConfiguration.Parameters = listConfiguration
        components.configuration?.builder(&configurationParameters)
        // This is weird. If the builder changed the object entirely then the changes would be ignored
        listConfiguration = (configurationParameters as? UICollectionLayoutListConfiguration) ?? listConfiguration
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        layout.configuration = layoutConfiguration

        return layout
    }

    private func section(for sectionIdentifier: SectionIdentifier) -> AnyListSection<SectionIdentifier, ItemIdentifier> {
        // Check sections with predicates for a match
        if let section = components.sections.first(where: { $0.predicate(sectionIdentifier) }) {
            return section
        }
        preconditionFailure("No sections to represent sectionIdentifier '\(sectionIdentifier)'.")
    }

    public func cell(for collectionView: UICollectionView, ItemIdentifier: ItemIdentifier, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.section(for: sectionIdentifier)
        let shouldUseHeaderCell = indexPath.item == 0
        if shouldUseHeaderCell,
           case .collapsable(let headerCell) = section.header {
            return headerCell.makeCell(with: ItemIdentifier, for: collectionView, at: indexPath)!
        }
        let cells = section.cells
        for cell in cells {
            if let cellView = cell.makeCell(with: ItemIdentifier, for: collectionView, at: indexPath) {
                return cellView
            }
        }
        preconditionFailure("Failed to create cell for item at '\(indexPath)'")
    }

    public func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionReusableView {
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


// MARK: - ListLayoutComponents

@available(iOS 14, *)
public struct ListLayoutComponents<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    let configuration: LayoutConfiguration?
    let header: LayoutHeader?
    let footer: LayoutFooter?
    let sections: [AnyListSection<SectionIdentifier, ItemIdentifier>]    
}


// MARK: - LayoutConfiguration

@available(iOS 14, *)
public struct LayoutConfiguration {

    // Only UICollectionLayoutListConfiguration needs to conform.
    // This protocol is used to restrict which properties can be modified so that the layout can't be broken.
    public protocol Parameters {
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


    let builder: (inout Parameters) -> Void


    public init(builder: @escaping (inout Parameters) -> Void) {
        self.builder = builder
    }
}


@available(iOS 14, *)
extension UICollectionLayoutListConfiguration: LayoutConfiguration.Parameters { }


// MARK: - AnyListSection

public struct AnyListSection<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    // MARK: Types

    public enum HeaderKind {
        case none
        case standard(Header<SectionIdentifier>)
        case collapsable(ListCell<ItemIdentifier>)
    }


    // MARK: Types

    public let predicate: ((SectionIdentifier) -> Bool)
    let header: HeaderKind
    let cells: [ListCell<ItemIdentifier>]
    let footer: Footer<SectionIdentifier>?


    // MARK: Internal

    func registerViews(in collectionView: UICollectionView) {
        for cell in cells {
            cell.registerCellClass(in: collectionView)
        }
        switch header {
        case .standard(let header):
            header.registerSupplementaryView(in: collectionView)
        case .collapsable(let cell):
            cell.registerCellClass(in: collectionView)
        case .none:
            break
        }
        footer?.registerSupplementaryView(in: collectionView)
    }

    func makeSupplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard case .standard(let header) = header else {
                return nil
            }
            return header.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
            
        case UICollectionView.elementKindSectionFooter:
            return footer?.makeSupplementaryView(for: collectionView, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
            
        default:
            return nil
        }
    }
}


// MARK: - ListCell

public struct ListCell<ItemIdentifier> {

    public typealias CellRegister = (UICollectionView) -> Void
    public typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifier) -> (UICollectionViewCell?)

    let cellRegistrar: CellRegister
    let cellProvider: CellProvider


    public init(
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellProvider: @escaping CellProvider
    ) {
        self.cellRegistrar = cellRegistrar
        self.cellProvider = cellProvider
    }

    func registerCellClass(in collectionView: UICollectionView) {
        cellRegistrar(collectionView)
    }

    func makeCell(with value: ItemIdentifier, for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell? {
        cellProvider(collectionView, indexPath, value)
    }
}
