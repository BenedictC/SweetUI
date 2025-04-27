import UIKit


// MARK: - Core types

public protocol Group {

    associatedtype ItemIdentifier: Hashable

    func cellsForRegistration() -> [Cell<ItemIdentifier>]
    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>]
    func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup
}

extension Group {

    static var defaultGroupSize: NSCollectionLayoutSize {
        NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100))
    }
}


public protocol GroupItem {

    associatedtype ItemIdentifier: Hashable

    func cellsForRegistration() -> [Cell<ItemIdentifier>]
    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>]
    func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem
}


// MARK: - AnyGroup

public struct AnyGroup<ItemIdentifier: Hashable>: Group {

    public let allCellsHandler: () -> [Cell<ItemIdentifier>]
    internal let itemSupplementaryTemplatesHandler: () -> [ItemSupplementaryTemplate<ItemIdentifier>]
    internal let makeLayoutGroupHandler: (NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup


    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        itemSupplementaryTemplatesHandler()
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        makeLayoutGroupHandler(environment)
    }

    public func cellsForRegistration() -> [Cell<ItemIdentifier>] {
         allCellsHandler()
    }

    func cells(forItemIndex index: Int) -> [Cell<ItemIdentifier>] {
        let cells = cellsForRegistration()
        let cellIndex = index % cells.count
        let cell = cells[cellIndex]
        return [cell]
    }
}


// MARK: - AxisGroup

public protocol AxisGroup: Group {

    static var axis: AxisGroupAxis { get }
    var groupSize: NSCollectionLayoutSize? { get }
    var items: [AnyGroupItem<ItemIdentifier>] { get }
    var layoutItemsFactory: (_ environment: NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem] { get }

    init(groupSize: NSCollectionLayoutSize?, items: [AnyGroupItem<ItemIdentifier>], layoutItemsFactory: @escaping (_ environment: NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem])
}


public enum AxisGroupAxis {
    case vertical, horizontal
}


extension AxisGroup {

    internal static func cellLayoutSize(forItemCount itemCount: Int, axis: AxisGroupAxis) -> NSCollectionLayoutSize {
        let fraction = 1.0 / Double(itemCount)
        return switch axis {
        case .vertical:
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(fraction))
        case .horizontal:
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        }
    }

    public func cellsForRegistration() -> [Cell<ItemIdentifier>] {
        items.reduce([], { $0 + $1.cellsForRegistration() })
    }

    public func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        items.reduce([], { $0 + $1.itemSupplementaryTemplates() })
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        let groupSize = self.groupSize ?? Self.defaultGroupSize
        let subItems = self.layoutItemsFactory(environment)
        switch Self.axis {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: subItems)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subItems)
        }
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        let size = self.groupSize ?? defaultSize
        let subItems = self.items.map({ $0.makeLayoutGroupItem(defaultSize: size, environment: environment) })
        switch Self.axis {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: subItems)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: subItems)
        }
    }
}


// MARK: - VGroup

public struct VGroup<ItemIdentifier: Hashable>: AxisGroup, GroupItem {

    public static var axis: AxisGroupAxis { .vertical }

    public let groupSize: NSCollectionLayoutSize?
    public let items: [AnyGroupItem<ItemIdentifier>]
    public let layoutItemsFactory: (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]

    public init(groupSize: NSCollectionLayoutSize?, items: [AnyGroupItem<ItemIdentifier>], layoutItemsFactory: @escaping (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]) {
        self.groupSize = groupSize
        self.items = items
        self.layoutItemsFactory = layoutItemsFactory
    }
}


// MARK: - HGroup

public struct HGroup<ItemIdentifier: Hashable>: AxisGroup, GroupItem {

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

public struct CustomGroup<ItemIdentifier: Hashable>: Group, GroupItem {

    let size: NSCollectionLayoutSize?
    public func cellsForRegistration() -> [Cell<ItemIdentifier>] {
        let count = numberOfCellsByCustomGroupUUID[uuid] ?? 1
        return Array(repeating: cell, count: count)
    }
    let itemProvider: NSCollectionLayoutGroupCustomItemProvider
    private let cell: Cell<ItemIdentifier>
    private let uuid: UUID

    public init(size: NSCollectionLayoutSize? = nil, cell: Cell<ItemIdentifier>, itemProvider: @escaping NSCollectionLayoutGroupCustomItemProvider) {
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
