import UIKit


// MARK: - Cell + GroupItem

extension _Cell: GroupItem where Content == CompositeLayoutCellContent<ItemIdentifier> {

    public func cellsForRegistration() -> [_Cell<CompositeLayoutCellContent<ItemIdentifier>, ItemIdentifier>] {
        [self]
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        // Cells are registered by registerCellClass so don't return again
        []
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        self.content.makeLayoutItem(defaultSize: defaultSize, environment: environment)
    }
}


// MARK: - Cell + Supplementaries

extension _Cell where Content == CompositeLayoutCellContent<ItemIdentifier> {

    func supplementaries(
        @SupplementaryComponentsBuilder<ItemIdentifier>
        _ componentsBuilder: () -> [Supplement<ItemIdentifier>]
    ) -> SupplementedGroupItem<ItemIdentifier> {
        let supplements = componentsBuilder()
        return SupplementedGroupItem(cell: self, supplements: supplements)
    }
}
