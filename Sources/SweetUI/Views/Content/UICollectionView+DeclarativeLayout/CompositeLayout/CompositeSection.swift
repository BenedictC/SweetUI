import UIKit


// MARK: - CompositeSection

@available(iOS 14, *) 
public struct CompositeSection<SectionIdentifier: Hashable, ItemIdentifier> {

    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)
    let components: CompositeSectionComponents<SectionIdentifier, ItemIdentifier>

    let orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?
    let interGroupSpacing: CGFloat?
    let contentInsets: NSDirectionalEdgeInsets?
    let contentInsetsReference: UIContentInsetsReference?
    let supplementaryContentInsetsReference: UIContentInsetsReference?
    let visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler??


    // MARK: View registration

    func registerDecorationViews(in layout: UICollectionViewLayout) {
        if let background = components.background {
            background.registerDecorationView(in: layout)
        }
    }

    func registerCellsAndSupplementaryViews(in collectionView: UICollectionView) {
        // Register the cells
        for cell in components.group.cellsForRegistration() {
            cell.registerCellClass(in: collectionView)
        }
        // Section supplementary
        for supplementary in components.sectionSupplementariesByElementKind.values {
            supplementary.registerSupplementaryView(in: collectionView)
        }
        // Item supplementary
        for template in components.itemSupplementaryTemplateByElementKind.values {
            template.registerItemSupplementaryView(in: collectionView)
        }
    }

    func registerItemReusableViews(in collectionView: UICollectionView) {
        // Item supplements
        for template in components.itemSupplementaryTemplateByElementKind.values {
            template.registerItemSupplementaryView(in: collectionView)
        }
    }


    // MARK: Template fetching

    func itemSupplementaryTemplate(for elementKind: String) -> ItemSupplementaryTemplate<ItemIdentifier>? {
        components.itemSupplementaryTemplateByElementKind[elementKind]
    }

    func cellTemplates(forItemIndex index: Int) -> [CompositeLayoutCell<ItemIdentifier>] {
        components.group.cells(forItemIndex: index)
    }


    // MARK: Factory

    func makeCompositionalLayoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let group = components.group.makeLayoutGroup(environment: environment)

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

        let boundarySupplementaryItem = components.sectionSupplementariesByElementKind.values
            .map { $0.makeLayoutBoundarySupplementaryItem() }

        section.boundarySupplementaryItems = boundarySupplementaryItem

        if let background = components.background {
            section.decorationItems = [background.makeLayoutDecorationItem()]
        }

        return section
    }
}


public struct CompositeSectionComponents<SectionIdentifier: Hashable, ItemIdentifier> {

    let group: AnyGroup<ItemIdentifier>
    let background: Background?
    let sectionSupplementariesByElementKind: [String: AnyBoundarySupplementaryComponent<SectionIdentifier>]
    let itemSupplementaryTemplateByElementKind: [String: ItemSupplementaryTemplate<ItemIdentifier>]
}
