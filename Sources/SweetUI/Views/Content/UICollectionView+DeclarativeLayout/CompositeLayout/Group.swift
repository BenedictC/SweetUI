import UIKit


// MARK: - Core types

public protocol Group<ItemIdentifier> {

    associatedtype ItemIdentifier

    func cellsForRegistration() -> [CompositeLayoutCell<ItemIdentifier>]
    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>]
    func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup
}


// MARK: - AnyGroup

public struct AnyGroup<ItemIdentifier>: Group {

    public let allCellsHandler: () -> [CompositeLayoutCell<ItemIdentifier>]
    internal let itemSupplementaryTemplatesHandler: () -> [ItemSupplementaryTemplate<ItemIdentifier>]
    internal let makeLayoutGroupHandler: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup


    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        itemSupplementaryTemplatesHandler()
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        makeLayoutGroupHandler(environment)
    }

    public func cellsForRegistration() -> [CompositeLayoutCell<ItemIdentifier>] {
         allCellsHandler()
    }

    func cells(forItemIndex index: Int) -> [CompositeLayoutCell<ItemIdentifier>] {
        let cells = cellsForRegistration()
        let cellIndex = index % cells.count
        let cell = cells[cellIndex]
        return [cell]
    }
}


// MARK: - VGroup

public struct VGroup<ItemIdentifier>: AxisGroup, GroupItem {

    public static var axis: AxisGroupAxis { .vertical }

    public let groupSize: NSCollectionLayoutSize?
    public let items: [AnyGroupItem<ItemIdentifier>]
    public let layoutItemsFactory: (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]

    public init(
        groupSize: NSCollectionLayoutSize?,
        items: [AnyGroupItem<ItemIdentifier>],
        layoutItemsFactory: @escaping (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]
    ) {
        self.groupSize = groupSize
        self.items = items
        self.layoutItemsFactory = layoutItemsFactory
    }
}


// MARK: - HGroup

public struct HGroup<ItemIdentifier>: AxisGroup, GroupItem {

    public static var axis: AxisGroupAxis { .horizontal }

    public let groupSize: NSCollectionLayoutSize?
    public let items: [AnyGroupItem<ItemIdentifier>]
    public let layoutItemsFactory: (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]

    public init(groupSize: NSCollectionLayoutSize?, items: [AnyGroupItem<ItemIdentifier>], layoutItemsFactory: @escaping (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]) {
        self.groupSize = groupSize
        self.items = items
        self.layoutItemsFactory = layoutItemsFactory
    }
}


// MARK: - CustomGroup

private var numberOfCellsByCustomGroupUUID = [UUID: Int]()

public struct CustomGroup<ItemIdentifier>: Group, GroupItem {

    let size: NSCollectionLayoutSize?
    public func cellsForRegistration() -> [CompositeLayoutCell<ItemIdentifier>] {
        let count = numberOfCellsByCustomGroupUUID[uuid] ?? 1
        return Array(repeating: cell, count: count)
    }
    let itemProvider: NSCollectionLayoutGroupCustomItemProvider
    private let cell: CompositeLayoutCell<ItemIdentifier>
    private let uuid: UUID

    public init(size: NSCollectionLayoutSize? = nil, cell: CompositeLayoutCell<ItemIdentifier>, itemProvider: @escaping NSCollectionLayoutGroupCustomItemProvider) {
        self.size = size
        self.cell = cell
        self.itemProvider = itemProvider
        self.uuid = UUID()
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        // items are not standard items, they are NSCollectionLayoutGroupCustomItem which don't support supplementary items
        []
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        let size = self.size ?? Self.defaultGroupSize
        return NSCollectionLayoutGroup.custom(layoutSize: size, itemProvider: { environment in
            let items = itemProvider(environment)
            numberOfCellsByCustomGroupUUID[uuid] = items.count
            return items
        })
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        let size = self.size ?? defaultSize
        return NSCollectionLayoutGroup.custom(layoutSize: size, itemProvider: { environment in
            let items = itemProvider(environment)
            numberOfCellsByCustomGroupUUID[uuid] = items.count
            return items
        })
    }
}


// MARK: - SupplementedGroup

public struct SupplementedGroup<ItemIdentifier>: Group {

    let group: AnyGroup<ItemIdentifier>
    let supplements: [Supplement<ItemIdentifier>]

    init<G: Group>(group: G, supplements: [Supplement<ItemIdentifier>]) where G.ItemIdentifier == ItemIdentifier {
        self.group = AnyGroup(
            allCellsHandler: group.cellsForRegistration,
            itemSupplementaryTemplatesHandler: group.itemSupplementaryTemplates,
            makeLayoutGroupHandler: group.makeLayoutGroup
        )
        self.supplements = supplements
    }

    public func cellsForRegistration() -> [CompositeLayoutCell<ItemIdentifier>] {
        fatalError()
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        fatalError()
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        fatalError()
    }
}
