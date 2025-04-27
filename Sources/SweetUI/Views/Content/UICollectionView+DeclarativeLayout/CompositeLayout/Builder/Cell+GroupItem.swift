import UIKit


// MARK: - Cell + GroupItem

extension Cell: GroupItem {

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        // Cells are registered separately
        []
    }

    public func cellsForRegistration() -> [Cell<ItemIdentifier>] { [self] }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        self.makeLayoutItem(defaultSize: defaultSize, environment: environment)
    }
}


// MARK: - Cell + Supplementaries

public extension Cell {

    func supplementaries(
        @SupplementaryComponentsBuilder<ItemIdentifier>
        _ componentsBuilder: () -> [Supplement<ItemIdentifier>]
    ) -> SupplementedGroupItem<ItemIdentifier> {
        let supplements = componentsBuilder()
        return SupplementedGroupItem(cell: self, supplements: supplements)
    }
}
