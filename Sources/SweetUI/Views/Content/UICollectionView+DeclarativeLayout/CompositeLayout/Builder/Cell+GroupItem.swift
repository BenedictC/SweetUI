import UIKit


// MARK: - Cell + GroupItem

extension CompositeLayoutCell {

    public func cellsForRegistration() -> [CompositeLayoutCell<ItemIdentifier>] {
        [self]
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        // Cells are registered by registerCellClass so don't return again
        []
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        self.makeLayoutItem(defaultSize: defaultSize, environment: environment)
    }
}


// MARK: - Cell + Supplementaries

extension CompositeLayoutCell {

    func supplementaries(
        @SupplementaryComponentsBuilder<ItemIdentifier>
        _ componentsBuilder: () -> [Supplement<ItemIdentifier>]
    ) -> SupplementedGroupItem<ItemIdentifier> {
        let supplements = componentsBuilder()
        return SupplementedGroupItem(cell: self, supplements: supplements)
    }
}
