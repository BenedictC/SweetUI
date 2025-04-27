// MARK: AnyGroup

public struct AnyGroupItem<ItemIdentifier: Hashable>: GroupItem {

    private let allCellsHandler: () -> [Cell<ItemIdentifier>]
    private let makeLayoutGroupItemHandler: (_ defaultSize: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem
    private let itemSupplementaryTemplatesHandler: () -> [ItemSupplementaryTemplate<ItemIdentifier>]

    init(
        allCellsHandler: @escaping () -> [Cell<ItemIdentifier>],
        makeLayoutGroupItemHandler: @escaping (_ defaultSize: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem,
        itemSupplementaryTemplatesHandler: @escaping () -> [ItemSupplementaryTemplate<ItemIdentifier>])
    {
        self.allCellsHandler = allCellsHandler
        self.makeLayoutGroupItemHandler = makeLayoutGroupItemHandler
        self.itemSupplementaryTemplatesHandler = itemSupplementaryTemplatesHandler
    }

    init<Item: GroupItem>(item: Item) where Item.ItemIdentifier == ItemIdentifier {
        self.allCellsHandler = item.cellsForRegistration
        self.makeLayoutGroupItemHandler = item.makeLayoutGroupItem(defaultSize:environment:)
        self.itemSupplementaryTemplatesHandler = item.itemSupplementaryTemplates
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        itemSupplementaryTemplatesHandler()
    }

    public func cellsForRegistration() -> [Cell<ItemIdentifier>] {
        allCellsHandler()
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        makeLayoutGroupItemHandler(defaultSize, environment)
    }
}


// MARK: - Group Builder

@resultBuilder
public struct GroupItemsBuilder<ItemIdentifier: Hashable> {

    public static func buildBlock<Item0: GroupItem>(_ item0: Item0) -> [AnyGroupItem<ItemIdentifier>] where Item0.ItemIdentifier == ItemIdentifier {
        let any0 = AnyGroupItem(item: item0)
        return [any0]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem>
    (_ item0: Item0, _ item1: Item1)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        return [any0, any1]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        return [any0, any1, any2]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier, Item3.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        let any3 = AnyGroupItem(item: item3)
        return [any0, any1, any2, any3]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem, Item4: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3, _ item4: Item4)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier, Item3.ItemIdentifier == ItemIdentifier, Item4.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        let any3 = AnyGroupItem(item: item3)
        let any4 = AnyGroupItem(item: item4)
        return [any0, any1, any2, any3, any4]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem, Item4: GroupItem, Item5: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3, _ item4: Item4, _ item5: Item5)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier, Item3.ItemIdentifier == ItemIdentifier, Item4.ItemIdentifier == ItemIdentifier, Item5.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        let any3 = AnyGroupItem(item: item3)
        let any4 = AnyGroupItem(item: item4)
        let any5 = AnyGroupItem(item: item5)
        return [any0, any1, any2, any3, any4, any5]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem, Item4: GroupItem, Item5: GroupItem, Item6: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3, _ item4: Item4, _ item5: Item5, _ item6: Item6)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier, Item3.ItemIdentifier == ItemIdentifier, Item4.ItemIdentifier == ItemIdentifier, Item5.ItemIdentifier == ItemIdentifier, Item6.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        let any3 = AnyGroupItem(item: item3)
        let any4 = AnyGroupItem(item: item4)
        let any5 = AnyGroupItem(item: item5)
        let any6 = AnyGroupItem(item: item6)
        return [any0, any1, any2, any3, any4, any5, any6]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem, Item4: GroupItem, Item5: GroupItem, Item6: GroupItem, Item7: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3, _ item4: Item4, _ item5: Item5, _ item6: Item6, _ item7: Item7)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier, Item3.ItemIdentifier == ItemIdentifier, Item4.ItemIdentifier == ItemIdentifier, Item5.ItemIdentifier == ItemIdentifier, Item6.ItemIdentifier == ItemIdentifier, Item7.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        let any3 = AnyGroupItem(item: item3)
        let any4 = AnyGroupItem(item: item4)
        let any5 = AnyGroupItem(item: item5)
        let any6 = AnyGroupItem(item: item6)
        let any7 = AnyGroupItem(item: item7)
        return [any0, any1, any2, any3, any4, any5, any6, any7]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem, Item4: GroupItem, Item5: GroupItem, Item6: GroupItem, Item7: GroupItem, Item8: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3, _ item4: Item4, _ item5: Item5, _ item6: Item6, _ item7: Item7, _ item8: Item8)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier, Item3.ItemIdentifier == ItemIdentifier, Item4.ItemIdentifier == ItemIdentifier, Item5.ItemIdentifier == ItemIdentifier, Item6.ItemIdentifier == ItemIdentifier, Item7.ItemIdentifier == ItemIdentifier, Item8.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        let any3 = AnyGroupItem(item: item3)
        let any4 = AnyGroupItem(item: item4)
        let any5 = AnyGroupItem(item: item5)
        let any6 = AnyGroupItem(item: item6)
        let any7 = AnyGroupItem(item: item7)
        let any8 = AnyGroupItem(item: item8)
        return [any0, any1, any2, any3, any4, any5, any6, any7, any8]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem, Item4: GroupItem, Item5: GroupItem, Item6: GroupItem, Item7: GroupItem, Item8: GroupItem, Item9: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3, _ item4: Item4, _ item5: Item5, _ item6: Item6, _ item7: Item7, _ item8: Item8, _ item9: Item9)
    -> [AnyGroupItem<ItemIdentifier>]
    where Item0.ItemIdentifier == ItemIdentifier, Item1.ItemIdentifier == ItemIdentifier, Item2.ItemIdentifier == ItemIdentifier, Item3.ItemIdentifier == ItemIdentifier, Item4.ItemIdentifier == ItemIdentifier, Item5.ItemIdentifier == ItemIdentifier, Item6.ItemIdentifier == ItemIdentifier, Item7.ItemIdentifier == ItemIdentifier, Item8.ItemIdentifier == ItemIdentifier, Item9.ItemIdentifier == ItemIdentifier
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        let any3 = AnyGroupItem(item: item3)
        let any4 = AnyGroupItem(item: item4)
        let any5 = AnyGroupItem(item: item5)
        let any6 = AnyGroupItem(item: item6)
        let any7 = AnyGroupItem(item: item7)
        let any8 = AnyGroupItem(item: item8)
        let any9 = AnyGroupItem(item: item9)
        return [any0, any1, any2, any3, any4, any5, any6, any7, any8, any9]
    }
}


@resultBuilder
public struct GroupItemBuilder<ItemIdentifier: Hashable> {

    public static func buildBlock<Item: GroupItem>(_ item: Item) -> AnyGroupItem<ItemIdentifier> where Item.ItemIdentifier == ItemIdentifier {
        AnyGroupItem(item: item)
    }
}


// MARK: - AxisGroup

public extension AxisGroup {

    init(
        size groupSize: NSCollectionLayoutSize? = nil,
        @GroupItemsBuilder<ItemIdentifier> items itemsBuilder: () -> [AnyGroupItem<ItemIdentifier>]
    ) {
        let items = itemsBuilder()
        let axis = Self.axis
        self.init(groupSize: groupSize, items: items, layoutItemsFactory: { environment in
            let itemSize = Self.cellLayoutSize(forItemCount: items.count, axis: axis)
            return items.map { $0.makeLayoutGroupItem(defaultSize: itemSize, environment: environment) }
        })
    }

    init(
        repetitions: Int,
        @GroupItemBuilder<ItemIdentifier> items itemBuilder: () -> AnyGroupItem<ItemIdentifier>
    ) {
        let item = itemBuilder()
        let axis = Self.axis
        self.init(groupSize: nil, items: [item]) { environment in
            let itemSize = Self.cellLayoutSize(forItemCount: repetitions, axis: axis)
            let layoutItem = item.makeLayoutGroupItem(defaultSize: itemSize, environment: environment)
            return Array(repeating: layoutItem, count: repetitions)
        }
    }

    init(
        minimumColumnWidth: CGFloat,
        @GroupItemBuilder<ItemIdentifier> item itemBuilder: () -> AnyGroupItem<ItemIdentifier>
    ) {
        let item = itemBuilder()
        let axis = Self.axis
        self.init(groupSize: nil, items: [item]) { environment in
            let repetitions = max(1, Int((environment.container.effectiveContentSize.width / minimumColumnWidth).nextDown))
            let itemSize = Self.cellLayoutSize(forItemCount: repetitions, axis: axis)
            let layoutItem = item.makeLayoutGroupItem(defaultSize: itemSize, environment: environment)
            return Array(repeating: layoutItem, count: repetitions)
        }
    }
}


// MARK: - Supplementaries

public extension Group {

    func supplementaries(
        @SupplementaryComponentsBuilder<ItemIdentifier>
        _ supplementsBuilder: () -> [Supplement<ItemIdentifier>]
    ) -> SupplementedGroup<ItemIdentifier> {
        let supplements = supplementsBuilder()
        return SupplementedGroup(
            group: self,
            supplements: supplements
        )
    }
}
