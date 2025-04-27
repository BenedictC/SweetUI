import UIKit


// MARK: - Cell

public struct Cell<ItemIdentifier: Hashable> {

    private let cellFactory: (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    private let cellRegistrar: (UICollectionView) -> Void
    // This only exists to support compositional layout. It's a mildly ugly hack
    private let makeLayoutItemHandler: (_ size: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem

    internal init(
        cellFactory: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?,
        cellRegistrar: @escaping (UICollectionView) -> Void,
        makeLayoutItemHandler: @escaping (NSCollectionLayoutSize, NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem)
    {
        self.cellFactory = cellFactory
        self.cellRegistrar = cellRegistrar
        self.makeLayoutItemHandler = makeLayoutItemHandler
    }

    func registerCellClass(in collectionView: UICollectionView) {
        cellRegistrar(collectionView)
    }

    func makeLayoutItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        makeLayoutItemHandler(defaultSize, environment)
    }

    func makeCell(with value: ItemIdentifier, for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell? {
        cellFactory(collectionView, indexPath, value)
    }
}


// MARK: - ???

public extension Cell {

    init<Value>(
        size: NSCollectionLayoutSize?,
        edgeSpacing: NSCollectionLayoutEdgeSpacing?,
        contentInsets: NSDirectionalEdgeInsets?,
        cellRegistrar: @escaping (UICollectionView) -> Void,
        value valueTransform: @escaping (ItemIdentifier) -> Value?,
        cellFactory: @escaping (UICollectionView, IndexPath, Value) -> UICollectionViewCell?
    ) {
        let makeLayoutItemHandler = { (defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem in
            let size = size ?? defaultSize
            let item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: [])
            if let edgeSpacing {
                item.edgeSpacing = edgeSpacing
            }
            if let contentInsets {
                item.contentInsets = contentInsets
            }
            return item
        }
        self.init(
            cellFactory: { collectionView, indexPath, ItemIdentifier in
                guard let value = valueTransform(ItemIdentifier) else {
                    return nil
                }
                return cellFactory(collectionView, indexPath, value)
            },
            cellRegistrar: cellRegistrar,
            makeLayoutItemHandler: makeLayoutItemHandler
        )
    }

    init(
        size: NSCollectionLayoutSize?,
        edgeSpacing: NSCollectionLayoutEdgeSpacing?,
        contentInsets: NSDirectionalEdgeInsets?,
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellFactory: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell?
    ) {
        let makeLayoutItemHandler = { (defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem in
            let size = size ?? defaultSize
            let item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: [])
            if let edgeSpacing {
                item.edgeSpacing = edgeSpacing
            }
            if let contentInsets {
                item.contentInsets = contentInsets
            }
            return item
        }
        self.init(
            cellFactory: cellFactory,
            cellRegistrar: cellRegistrar,
            makeLayoutItemHandler: makeLayoutItemHandler
        )
    }
}


// MARK: - Cell + ReusableViewConfigurable

public typealias CellConfigurable = UICollectionViewCell & ReusableViewConfigurable

public extension Cell {

    init<CellClass: CellConfigurable, Value>(
        _ cellClass: CellClass.Type,
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        value valueTransform: @escaping ((ItemIdentifier) -> Value?)
    ) where Value == CellClass.Value {
        let reuseIdentifier = UniqueIdentifier("\(cellClass.self)").value
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, value: Value) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellClass
            cell.configure(using: value)
            return cell
        }
        let cellRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(CellClass.self, forCellWithReuseIdentifier: reuseIdentifier)
        }
        self.init(
            size: size,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            value: valueTransform,
            cellFactory: cellFactory
        )
    }

    init<CellClass: CellConfigurable>(
        _ cellClass: CellClass.Type,
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil
    ) where ItemIdentifier == CellClass.Value {
        let reuseIdentifier = UniqueIdentifier("\(cellClass.self)").value
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: ItemIdentifier) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellClass
            cell.configure(using: itemIdentifier)
            return cell
        }
        let cellRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(CellClass.self, forCellWithReuseIdentifier: reuseIdentifier)
        }
        self.init(
            size: size,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            cellFactory: cellFactory
        )
    }
}


public extension Cell {

    init<Value>(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        value: @escaping ((ItemIdentifier) -> Value?),
        body bodyFactory: @escaping (OneWayBinding<Value>) -> UIView
    ) {
        let cellClass = ValuePublishingCell<Value>.self
        let reuseIdentifier = UniqueIdentifier("\(cellClass.self)").value
        let cellRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        }
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<Value>
            cell.initialize(bindingOptions: .default, bodyFactory: bodyFactory)
            cell.configure(using: value)
            return cell
        }
        self.init(
            size: size,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            value: value,
            cellFactory: cellFactory
        )
    }

    init(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        body bodyFactory: @escaping (OneWayBinding<ItemIdentifier>) -> UIView
    ) {
        let cellClass = ValuePublishingCell<ItemIdentifier>.self
        let reuseIdentifier = UniqueIdentifier("\(cellClass.self)").value
        let cellRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        }
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: ItemIdentifier) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<ItemIdentifier>
            cell.initialize(bindingOptions: .default, bodyFactory: bodyFactory)
            cell.configure(using: itemIdentifier)
            return cell
        }
        self.init(
            size: size,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            cellFactory: cellFactory
        )
    }
}


// MARK: - OneOf

public extension Cell {

    init(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        dropsDuplicateValues: Bool = true,
        content contentFactory: @escaping (ItemIdentifier) -> UIView
    ) {
        let cellClass = ValuePublishingCell<ItemIdentifier>.self
        let reuseIdentifier = UniqueIdentifier("\(cellClass.self)").value
        let cellRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        }
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: ItemIdentifier) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<ItemIdentifier>
            cell.initialize(bindingOptions: .default, bodyFactory: { publisher in
                OneOf(value: publisher, dropDuplicateValues: dropsDuplicateValues, content: contentFactory)
            })
            cell.configure(using: itemIdentifier)
            return cell
        }
        self.init(
            size: size,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            cellFactory: cellFactory
        )
    }
}
