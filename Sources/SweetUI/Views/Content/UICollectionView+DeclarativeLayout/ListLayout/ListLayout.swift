import Foundation
import UIKit


// MARK: - ListLayout

@available(iOS 15, *)
public struct ListLayout<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: CollectionViewLayoutStrategy {

    let appearance: UICollectionLayoutListConfiguration.Appearance
    let components: ListLayoutComponents<SectionIdentifier, ItemIdentifier>
    public let behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemIdentifier>

    private let emptyFooter = SectionFooter<SectionIdentifier> { _, _ in Spacer(height: 0) }


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
        if let background = self.components.background {
            collectionView.backgroundView = background.view
        }
        components.header?.registerReusableViews(in: collectionView)
        components.footer?.registerReusableViews(in: collectionView)
        for section in components.sections {
            section.registerViews(in: collectionView)
        }
        emptyFooter.registerReusableViews(in: collectionView)
    }

    public func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionViewLayout {
        let initialListConfiguration = UICollectionLayoutListConfiguration(appearance: appearance)
        let compositionalConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        // # Apply the user supplied configurations
        var finalListConfiguration: UICollectionLayoutListConfiguration
        if let configurationBuilder = components.configuration {
            let (_, listConfig) = configurationBuilder.apply(
                toCompositionalLayoutConfiguration: compositionalConfiguration,
                listConfiguration: initialListConfiguration
            )
            finalListConfiguration = listConfig
        } else {
            finalListConfiguration = initialListConfiguration
        }

        // # Add configuration options that are specified else where
        // ## Section header/footer
        let firstHeader = components.sections[0].header // Sections must all have the same Header type
        switch firstHeader {
        case .collapsable:
            finalListConfiguration.headerMode = .firstItemInSection
        case .standard:
            finalListConfiguration.headerMode = .supplementary
        case .none:
            break
        }
        let hasFooter = components.sections.contains { $0.footer != nil }
        if hasFooter {
            finalListConfiguration.footerMode = .supplementary
        }
        // ## Layout header/footer
        if let header = components.header {
            let headerItem = header.makeLayoutBoundarySupplementaryItem()
            compositionalConfiguration.boundarySupplementaryItems += [headerItem]
        }
        if let footer = components.footer {
            let footerItem = footer.makeLayoutBoundarySupplementaryItem()
            compositionalConfiguration.boundarySupplementaryItems += [footerItem]
        }

        // # Configure the layout (finally!)
        let layout = UICollectionViewCompositionalLayout.list(using: finalListConfiguration)
        layout.configuration = compositionalConfiguration
        return layout
    }

    private func makeSection(for sectionIdentifier: SectionIdentifier) -> AnyListSection<SectionIdentifier, ItemIdentifier> {
        // Check sections with predicates for a match
        if let section = components.sections.first(where: { $0.predicate(sectionIdentifier) }) {
            return section
        }
        preconditionFailure("No sections to represent sectionIdentifier '\(sectionIdentifier)'.")
    }

    public func makeCell(for collectionView: UICollectionView, itemIdentifier: ItemIdentifier, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell {
        let section = self.makeSection(for: sectionIdentifier)
        let shouldUseHeaderCell = indexPath.item == 0
        if shouldUseHeaderCell,
           case .collapsable(let headerCell) = section.header {
            return headerCell.makeCell(with: itemIdentifier, for: collectionView, at: indexPath)!
        }
        let cells = section.cells
        for cell in cells {
            if let cellView = cell.makeCell(with: itemIdentifier, for: collectionView, at: indexPath) {
                return cellView
            }
        }
        preconditionFailure("Failed to create cell for item at '\(indexPath)'")
    }

    public func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, at indexPath: IndexPath, dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionReusableView {
        // # Layout supplementary views
        if let header = components.header,
           elementKind == header.elementKind {
           let headerView = header.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: ())
           guard let headerView else {
               preconditionFailure("Failed to create header")
           }
           return headerView
        }
        if let footer = components.footer,
           elementKind == footer.elementKind {
           let footerView = footer.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: ())
           guard let footerView else {
               preconditionFailure("Failed to create footer")
           }
           return footerView
        }

        // # Section supplementary views
        guard let sectionIdentifier = dataSource.sectionIdentifier(forSectionAtIndex: indexPath.section) else {
            preconditionFailure("Invalid section index")
        }
        let section = makeSection(for: sectionIdentifier)
        let view = section.makeSupplementaryView(ofKind: elementKind, for: collectionView, at: indexPath, sectionIdentifier: sectionIdentifier)
        if let view {
            return view
        }
        let isEmptyFooter = elementKind == emptyFooter.elementKind
        if isEmptyFooter,
           let footer = emptyFooter.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: sectionIdentifier) {
            return footer
        }
        preconditionFailure("Failed to create supplementary view of elementKind '\(elementKind)' for indexPath '\(indexPath)'")
    }
}


// MARK: - ListLayoutComponents

@available(iOS 15, *)
public struct ListLayoutComponents<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    let configuration: LayoutConfiguration?
    let header: LayoutHeader?
    let footer: LayoutFooter?
    let background: LayoutBackground?
    let sections: [AnyListSection<SectionIdentifier, ItemIdentifier>]
}


// MARK: - LayoutConfiguration

@available(iOS 15, *)
public struct LayoutConfiguration {

    public struct Configuration {

        // UICollectionLayoutListConfiguration
        public var showsSeparators: Bool
        public var separatorConfiguration: UIListSeparatorConfiguration
        public var itemSeparatorHandler: UICollectionLayoutListConfiguration.ItemSeparatorHandler?
        public var backgroundColor: UIColor?
        public var leadingSwipeActionsConfigurationProvider: UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider?
        public var trailingSwipeActionsConfigurationProvider: UICollectionLayoutListConfiguration.SwipeActionsConfigurationProvider?
        public var headerTopPadding: CGFloat?

        // UICollectionViewCompositionalLayoutConfiguration
        public var scrollDirection: UICollectionView.ScrollDirection
        public var interSectionSpacing: CGFloat
        public var contentInsetsReference: UIContentInsetsReference
        public var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem]
    }


    private let builder: (inout Configuration) -> Void

    public init(builder: @escaping (inout Configuration) -> Void) {
        self.builder = builder
    }

    func apply(
        toCompositionalLayoutConfiguration compositional: UICollectionViewCompositionalLayoutConfiguration,
        listConfiguration list: UICollectionLayoutListConfiguration
    ) -> (compositional: UICollectionViewCompositionalLayoutConfiguration, list: UICollectionLayoutListConfiguration) {
        // Collate the default configuration
        var configuration = Configuration(
            // UICollectionLayoutListConfiguration
            showsSeparators: list.showsSeparators,
            separatorConfiguration: list.separatorConfiguration,
            itemSeparatorHandler: list.itemSeparatorHandler,
            backgroundColor: list.backgroundColor,
            leadingSwipeActionsConfigurationProvider: list.leadingSwipeActionsConfigurationProvider,
            trailingSwipeActionsConfigurationProvider: list.trailingSwipeActionsConfigurationProvider,
            headerTopPadding: list.headerTopPadding,

            // UICollectionViewCompositionalLayoutConfiguration
            scrollDirection: compositional.scrollDirection,
            interSectionSpacing: compositional.interSectionSpacing,
            contentInsetsReference: compositional.contentInsetsReference,
            boundarySupplementaryItems: compositional.boundarySupplementaryItems
        )
        // Apply the updates to the building
        builder(&configuration)

        // Write the updates back to the results
        var newList = UICollectionLayoutListConfiguration(appearance: list.appearance)
        newList.showsSeparators = configuration.showsSeparators
        newList.separatorConfiguration = configuration.separatorConfiguration
        newList.itemSeparatorHandler = configuration.itemSeparatorHandler
        newList.backgroundColor = configuration.backgroundColor
        newList.leadingSwipeActionsConfigurationProvider = configuration.leadingSwipeActionsConfigurationProvider
        newList.trailingSwipeActionsConfigurationProvider = configuration.trailingSwipeActionsConfigurationProvider
        newList.headerTopPadding = configuration.headerTopPadding
        // UICollectionViewCompositionalLayoutConfiguration
        compositional.scrollDirection = configuration.scrollDirection
        compositional.interSectionSpacing = configuration.interSectionSpacing
        compositional.contentInsetsReference = configuration.contentInsetsReference
        compositional.boundarySupplementaryItems = configuration.boundarySupplementaryItems

        return (compositional, newList)
    }
}


// MARK: - AnyListSection

public struct AnyListSection<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    // MARK: Types

    public enum HeaderKind {
        case none
        case standard(SectionHeader<SectionIdentifier>)
        case collapsable(ListCell<ItemIdentifier>)
    }


    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)
    let header: HeaderKind
    let cells: [ListCell<ItemIdentifier>]
    let footer: SectionFooter<SectionIdentifier>?

    init(predicate: @escaping (SectionIdentifier) -> Bool, header: HeaderKind, cells: [ListCell<ItemIdentifier>], footer: SectionFooter<SectionIdentifier>?) {
        self.predicate = predicate
        self.header = header
        self.cells = cells
        self.footer = footer
    }


    // MARK: Registration

    func registerViews(in collectionView: UICollectionView) {
        for cell in cells {
            cell.registerCellClass(in: collectionView)
        }
        switch header {
        case .standard(let header):
            header.registerReusableViews(in: collectionView)
        case .collapsable(let cell):
            cell.registerCellClass(in: collectionView)
        case .none:
            break
        }
        footer?.registerReusableViews(in: collectionView)
    }


    // MARK: View creation

    func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, at indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard case .standard(let header) = header else {
                return nil
            }
            return header.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: sectionIdentifier)

        case UICollectionView.elementKindSectionFooter:
            return footer?.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: sectionIdentifier)
            
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
