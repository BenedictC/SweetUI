import UIKit


// MARK: - Group

public protocol Group {

    associatedtype ItemValue: Hashable

    func allCells() -> [Cell<ItemValue>]
    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>]
    func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup
}

extension Group {

    static var defaultSize: NSCollectionLayoutSize {
        NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100))
    }
}


public struct AnyGroup<ItemValue: Hashable>: Group {

    public let allCellsHandler: () -> [Cell<ItemValue>]
    private let itemSupplementaryTemplatesHandler: () -> [ItemSupplementaryTemplate<ItemValue>]
    private let makeLayoutGroupHandler: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup

    internal init(
        allCellsHandler: @escaping () -> [Cell<ItemValue>],
        itemSupplementaryTemplatesHandler: @escaping () -> [ItemSupplementaryTemplate<ItemValue>],
        makeLayoutGroupHandler: @escaping (NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup)
    {
        self.allCellsHandler = allCellsHandler
        self.itemSupplementaryTemplatesHandler = itemSupplementaryTemplatesHandler
        self.makeLayoutGroupHandler = makeLayoutGroupHandler
    }

    init<G: Group>(group: G) where G.ItemValue == ItemValue {
        self.allCellsHandler = group.allCells
        self.makeLayoutGroupHandler = group.makeLayoutGroup
        self.itemSupplementaryTemplatesHandler = group.itemSupplementaryTemplates
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        itemSupplementaryTemplatesHandler()
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        makeLayoutGroupHandler(environment)
    }

    public func allCells() -> [Cell<ItemValue>] {
         allCellsHandler()
    }

    func cell(forItemIndex index: Int) -> Cell<ItemValue> {
        let cells = allCells()
        let cellIndex = index % cells.count
        let cell = cells[cellIndex]
        return cell
    }
}


public protocol GroupItem {

    associatedtype ItemValue: Hashable

    func allCells() -> [Cell<ItemValue>]
    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>]
    func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem
}


public struct AnyGroupItem<ItemValue: Hashable>: GroupItem {

    private let allCellsHandler: () -> [Cell<ItemValue>]
    private let makeLayoutGroupItemHandler: (_ defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem
    private let itemSupplementaryTemplatesHandler: () -> [ItemSupplementaryTemplate<ItemValue>]

    internal init(
        allCellsHandler: @escaping () -> [Cell<ItemValue>],
        makeLayoutGroupItemHandler: @escaping (_ defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem,
        itemSupplementaryTemplatesHandler: @escaping () -> [ItemSupplementaryTemplate<ItemValue>])
    {
        self.allCellsHandler = allCellsHandler
        self.makeLayoutGroupItemHandler = makeLayoutGroupItemHandler
        self.itemSupplementaryTemplatesHandler = itemSupplementaryTemplatesHandler
    }

    init<Item: GroupItem>(item: Item) where Item.ItemValue == ItemValue {
        self.allCellsHandler = item.allCells
        self.makeLayoutGroupItemHandler = item.makeLayoutGroupItem(defaultSize:)
        self.itemSupplementaryTemplatesHandler = item.itemSupplementaryTemplates
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        itemSupplementaryTemplatesHandler()
    }

    public func allCells() -> [Cell<ItemValue>] {
        allCellsHandler()
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem {
        makeLayoutGroupItemHandler(defaultSize)
    }
}


@resultBuilder
public struct GroupItemsBuilder<ItemValue: Hashable> {

    public static func buildBlock<Item0: GroupItem>(_ item0: Item0) -> [AnyGroupItem<ItemValue>] where Item0.ItemValue == ItemValue {
        let any0 = AnyGroupItem(item: item0)
        return [any0]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem>
    (_ item0: Item0, _ item1: Item1)
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        return [any0, any1]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2)
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue
    {
        let any0 = AnyGroupItem(item: item0)
        let any1 = AnyGroupItem(item: item1)
        let any2 = AnyGroupItem(item: item2)
        return [any0, any1, any2]
    }

    public static func buildBlock
    <Item0: GroupItem, Item1: GroupItem, Item2: GroupItem, Item3: GroupItem>
    (_ item0: Item0, _ item1: Item1, _ item2: Item2, _ item3: Item3)
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue, Item3.ItemValue == ItemValue
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
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue, Item3.ItemValue == ItemValue, Item4.ItemValue == ItemValue
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
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue, Item3.ItemValue == ItemValue, Item4.ItemValue == ItemValue, Item5.ItemValue == ItemValue
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
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue, Item3.ItemValue == ItemValue, Item4.ItemValue == ItemValue, Item5.ItemValue == ItemValue, Item6.ItemValue == ItemValue
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
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue, Item3.ItemValue == ItemValue, Item4.ItemValue == ItemValue, Item5.ItemValue == ItemValue, Item6.ItemValue == ItemValue, Item7.ItemValue == ItemValue
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
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue, Item3.ItemValue == ItemValue, Item4.ItemValue == ItemValue, Item5.ItemValue == ItemValue, Item6.ItemValue == ItemValue, Item7.ItemValue == ItemValue, Item8.ItemValue == ItemValue
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
    -> [AnyGroupItem<ItemValue>]
    where Item0.ItemValue == ItemValue, Item1.ItemValue == ItemValue, Item2.ItemValue == ItemValue, Item3.ItemValue == ItemValue, Item4.ItemValue == ItemValue, Item5.ItemValue == ItemValue, Item6.ItemValue == ItemValue, Item7.ItemValue == ItemValue, Item8.ItemValue == ItemValue, Item9.ItemValue == ItemValue
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


// MARK: - AxisGroup

public protocol AxisGroup: Group {

    var axis: AxisGroupAxis { get }

    var size: NSCollectionLayoutSize? { get }
    var items: [AnyGroupItem<ItemValue>] { get }
    init(size: NSCollectionLayoutSize?, items: [AnyGroupItem<ItemValue>])
}


public enum AxisGroupAxis {
    case vertical, horizontal
}


extension AxisGroup {

    public func allCells() -> [Cell<ItemValue>] {
        items.reduce([], { $0 + $1.allCells() })
    }

    private var subItemsDefaultSize: NSCollectionLayoutSize {
        let subItemFraction = 1.0 / Double(items.count)
        switch axis {
        case .vertical:
            return NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(subItemFraction))
        case .horizontal:
            return NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(subItemFraction),
                heightDimension: .fractionalHeight(1))
        }
    }

    public init(
        size: NSCollectionLayoutSize? = nil,
        @GroupItemsBuilder<ItemValue> items itemsBuilder: () -> [AnyGroupItem<ItemValue>])
    {
        self.init(size: size, items: itemsBuilder())
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        items.reduce([], { $0 + $1.itemSupplementaryTemplates() })
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        let size = self.size ?? Self.defaultSize
        let subItemsDefaultSize = self.subItemsDefaultSize
        let subItems = self.items.map({ $0.makeLayoutGroupItem(defaultSize: subItemsDefaultSize) })
        switch axis {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: subItems)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: subItems)
        }
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem {
        let size = self.size ?? defaultSize
        let subItemsDefaultSize = self.subItemsDefaultSize
        let subItems = self.items.map({ $0.makeLayoutGroupItem(defaultSize: subItemsDefaultSize) })
        switch axis {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: subItems)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: subItems)
        }
    }
}


// MARK: - VGroup

public struct VGroup<ItemValue: Hashable>: AxisGroup, GroupItem {

    public let axis = AxisGroupAxis.vertical

    public let size: NSCollectionLayoutSize?
    public let items: [AnyGroupItem<ItemValue>]

    public init(size: NSCollectionLayoutSize? = nil, items: [AnyGroupItem<ItemValue>]) {
        self.size = size
        self.items = items
    }
}


// MARK: - HGroup

public struct HGroup<ItemValue: Hashable>: AxisGroup, GroupItem {

    public let axis = AxisGroupAxis.horizontal

    public let size: NSCollectionLayoutSize?
    public let items: [AnyGroupItem<ItemValue>]

    public init(size: NSCollectionLayoutSize? = nil, items: [AnyGroupItem<ItemValue>]) {
        self.size = size
        self.items = items
    }
}


// MARK: - CustomGroup

private var numberOfCellsByCustomGroupUUID = [UUID: Int]()

public struct CustomGroup<ItemValue: Hashable>: Group, GroupItem {

    let size: NSCollectionLayoutSize?
    public func allCells() -> [Cell<ItemValue>] {
        let count = numberOfCellsByCustomGroupUUID[uuid] ?? 1
        return Array(repeating: cell, count: count)
    }
    let itemProvider: NSCollectionLayoutGroupCustomItemProvider
    private let cell: Cell<ItemValue>
    private let uuid: UUID

    public init(size: NSCollectionLayoutSize? = nil, cell: Cell<ItemValue>, itemProvider: @escaping NSCollectionLayoutGroupCustomItemProvider) {
        self.size = size
        self.cell = cell
        self.itemProvider = itemProvider
        self.uuid = UUID()
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemValue>] {
        // items are not standard items, they are NSCollectionLayoutGroupCustomItem which don't support supplementary items
        []
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        let size = self.size ?? Self.defaultSize
        return NSCollectionLayoutGroup.custom(layoutSize: size, itemProvider: { environment in
            let items = itemProvider(environment)
            numberOfCellsByCustomGroupUUID[uuid] = items.count
            return items
        })
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutItem {
        let size = self.size ?? defaultSize
        return NSCollectionLayoutGroup.custom(layoutSize: size, itemProvider: { environment in
            let items = itemProvider(environment)
            numberOfCellsByCustomGroupUUID[uuid] = items.count
            return items
        })
    }
}
