import Foundation
import UIKit
import SweetUI
import Combine


// MARK: - CollectionViewStrategy

protocol CollectionViewStrategy {

    associatedtype SectionIdentifier: Hashable
    associatedtype ItemValue: Hashable

    func registerReusableViews(in collectionView: UICollectionView)
    func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionViewLayout
    func cell(for collectionView: UICollectionView, itemValue: ItemValue, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell
    func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemValue>) -> UICollectionReusableView
}


// MARK: - ReusableViewConfigurable

public protocol ReusableViewConfigurable: UICollectionReusableView {

    associatedtype Value

    func configure(using value: Value)
}


// MARK: - BoundarySupplementaryComponent/AnyBoundarySupplementaryComponent

public protocol BoundarySupplementaryComponent {

    associatedtype SectionIdentifier

    var elementKind: String { get }

    func registerSupplementaryView(in collectionView: UICollectionView)
    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem
    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView
}


struct AnyBoundarySupplementaryComponent<SectionIdentifier>: BoundarySupplementaryComponent {

    let elementKind: String
    let registerSupplementaryViewHandler: (_ collectionView: UICollectionView) -> Void
    let makeLayoutBoundarySupplementaryItemHandler: () -> NSCollectionLayoutBoundarySupplementaryItem
    let makeSupplementaryViewHandler: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ sectionIdentifier: SectionIdentifier) -> UICollectionReusableView

    init(
        elementKind: String,
        registerSupplementaryViewHandler: @escaping (_ collectionView: UICollectionView) -> Void,
        makeLayoutBoundarySupplementaryItemHandler: @escaping () -> NSCollectionLayoutBoundarySupplementaryItem,
        makeSupplementaryViewHandler: @escaping (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ sectionIdentifier: SectionIdentifier) -> UICollectionReusableView
    ) {
        self.elementKind = elementKind
        self.registerSupplementaryViewHandler = registerSupplementaryViewHandler
        self.makeLayoutBoundarySupplementaryItemHandler = makeLayoutBoundarySupplementaryItemHandler
        self.makeSupplementaryViewHandler = makeSupplementaryViewHandler
    }

    init<T: BoundarySupplementaryComponent>(erased: T) where T.SectionIdentifier == SectionIdentifier {
        self.elementKind = erased.elementKind
        registerSupplementaryViewHandler = erased.registerSupplementaryView(in:)
        makeLayoutBoundarySupplementaryItemHandler = erased.makeLayoutBoundarySupplementaryItem
        makeSupplementaryViewHandler = erased.makeSupplementaryView(for:indexPath:sectionIdentifier:)
    }

    func registerSupplementaryView(in collectionView: UICollectionView) {
        registerSupplementaryViewHandler(collectionView)
    }

    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        makeLayoutBoundarySupplementaryItemHandler()
    }

    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        makeSupplementaryViewHandler(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - BoundarySupplementaryComponentFactory

public protocol BoundarySupplementaryComponentFactory: BoundarySupplementaryComponent {

    static var defaultAlignment: NSRectAlignment { get }
    static var elementKind: String { get }

    init(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        alignment: NSRectAlignment,
        absoluteOffset: CGPoint,
        extendsBoundary: Bool?,
        pinToVisibleBounds: Bool?,
        viewRegistrar: @escaping (UICollectionView) -> Void,
        viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView)
}


extension BoundarySupplementaryComponentFactory {

    init<View: ReusableViewConfigurable>(
        _ viewClass: View.Type,
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        alignment: NSRectAlignment = Self.defaultAlignment,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool? = nil,
        pinToVisibleBounds: Bool? = nil)
    where View.Value == SectionIdentifier
    {
        let elementKind = Self.elementKind
        let reuseIdentifier = "\(elementKind) \(UUID())"
        let viewRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! View
            view.configure(using: sectionIdentifier)
            return view
        }
        self.init(
            width: width,
            height: height,
            alignment: alignment,
            absoluteOffset: absoluteOffset,
            extendsBoundary: extendsBoundary,
            pinToVisibleBounds: pinToVisibleBounds,
            viewRegistrar: viewRegistrar,
            viewFactory: viewFactory)
    }
}

extension BoundarySupplementaryComponentFactory {

    init(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        alignment: NSRectAlignment = Self.defaultAlignment,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool? = nil,
        pinToVisibleBounds: Bool? = nil,
        configuration: @escaping (UICollectionViewListCell, SectionIdentifier) -> Void)
    {
        let viewClass = UICollectionViewListCell.self
        let elementKind = Self.elementKind
        let reuseIdentifier = "\(elementKind) \(UUID())"
        let viewRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! UICollectionViewListCell
            configuration(view, sectionIdentifier)
            return view
        }
        self.init(
            width: width,
            height: height,
            alignment: alignment,
            absoluteOffset: absoluteOffset,
            extendsBoundary: extendsBoundary,
            pinToVisibleBounds: pinToVisibleBounds,
            viewRegistrar: viewRegistrar,
            viewFactory: viewFactory)
    }
}

extension BoundarySupplementaryComponentFactory {

    init(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        alignment: NSRectAlignment = Self.defaultAlignment,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool? = nil,
        pinToVisibleBounds: Bool? = nil,
        body bodyFactory: @escaping (AnyPublisher<SectionIdentifier, Never>) -> UIView)
    {
        let viewClass = ValuePublishingCell<SectionIdentifier>.self
        let elementKind = Self.elementKind
        let reuseIdentifier = "\(elementKind) \(UUID())"
        let viewRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<SectionIdentifier>
            view.bodyFactory = bodyFactory
            view.configure(using: sectionIdentifier)
            return view
        }
        self.init(
            width: width,
            height: height,
            alignment: alignment,
            absoluteOffset: absoluteOffset,
            extendsBoundary: extendsBoundary,
            pinToVisibleBounds: pinToVisibleBounds,
            viewRegistrar: viewRegistrar,
            viewFactory: viewFactory)
    }
}


// MARK: - Header

struct Header<SectionIdentifier>: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    static var elementKind: String { UICollectionView.elementKindSectionHeader }
    static var defaultAlignment: NSRectAlignment { .topLeading }
    var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }


    func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset)
        if let extendsBoundary {
            layoutItem.extendsBoundary = extendsBoundary
        }
        if let pinToVisibleBounds {
            layoutItem.pinToVisibleBounds = pinToVisibleBounds
        }
        return layoutItem
    }

    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - Footer

struct Footer<SectionIdentifier>: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    static var defaultAlignment: NSRectAlignment { .bottomLeading }
    static var elementKind: String { UICollectionView.elementKindSectionFooter }
    var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }
    

    func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset)
        if let extendsBoundary {
            layoutItem.extendsBoundary = extendsBoundary
        }
        if let pinToVisibleBounds {
            layoutItem.pinToVisibleBounds = pinToVisibleBounds
        }
        return layoutItem
    }

    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - LayoutHeader

struct LayoutHeader: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    typealias SectionIdentifier = Void

    static var defaultAlignment: NSRectAlignment { .topLeading }
    static var elementKind: String { "Layout Header" }
    var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }


    func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset)
        if let extendsBoundary {
            layoutItem.extendsBoundary = extendsBoundary
        }
        if let pinToVisibleBounds {
            layoutItem.pinToVisibleBounds = pinToVisibleBounds
        }
        return layoutItem
    }

    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - LayoutFooter

struct LayoutFooter: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    typealias SectionIdentifier = Void

    static var defaultAlignment: NSRectAlignment { .bottomLeading }
    static var elementKind: String { "Layout Footer" }
    var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }

    func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let layoutItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: elementKind,
            alignment: alignment,
            absoluteOffset: absoluteOffset)
        if let extendsBoundary {
            layoutItem.extendsBoundary = extendsBoundary
        }
        if let pinToVisibleBounds {
            layoutItem.pinToVisibleBounds = pinToVisibleBounds
        }
        return layoutItem
    }

    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - DecorationComponent

public protocol DecorationComponent {

    associatedtype SectionIdentifier

    var elementKind: String { get }

    func registerSupplementaryView(in layout: UICollectionViewCompositionalLayout)
    func makeLayoutDecorationItem() -> NSCollectionLayoutDecorationItem
    func makeDecorationView(for collectionView: UICollectionView, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView
}


// MARK: - Background

struct Background<SectionIdentifier>: DecorationComponent {

    let elementKind: String
    let zIndex: Int?
    private let viewRegistrar: (UICollectionViewCompositionalLayout) -> Void
    private let viewFactory: (UICollectionView, SectionIdentifier) -> UICollectionReusableView

    init(elementKind: String, zIndex: Int? = nil) {
        self.elementKind = elementKind
        self.zIndex = zIndex
        let viewClass = UICollectionReusableView.self
        self.viewRegistrar = { layout in
            layout.register(viewClass, forDecorationViewOfKind: elementKind)
        }
        self.viewFactory = { _, _ in
            let view = viewClass.init()
            view.backgroundColor = .purple
            return view
        }
    }

    func registerSupplementaryView(in layout: UICollectionViewCompositionalLayout) {
        viewRegistrar(layout)
    }

    func makeLayoutDecorationItem() -> NSCollectionLayoutDecorationItem {
        NSCollectionLayoutDecorationItem.background(elementKind: elementKind)
    }

    func makeDecorationView(for collectionView: UICollectionView, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, sectionIdentifier)
    }
}


// MARK: - LayoutBackground

typealias LayoutBackground = Background<Void>



// MARK: - Cell

public struct Cell <ItemValue: Hashable> {

    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let edgeSpacing: NSCollectionLayoutEdgeSpacing?
    let contentInsets: NSDirectionalEdgeInsets?
    private let cellFactory: (UICollectionView, IndexPath, ItemValue) -> UICollectionViewCell
    private let cellRegistrar: (UICollectionView) -> Void


    internal init(
        width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        edgeSpacing: NSCollectionLayoutEdgeSpacing?,
        contentInsets: NSDirectionalEdgeInsets?,
        cellRegistrar: @escaping (UICollectionView) -> Void,
        cellFactory: @escaping (UICollectionView, IndexPath, ItemValue) -> UICollectionViewCell)
    {
        self.width = width
        self.height = height
        self.edgeSpacing = edgeSpacing
        self.contentInsets = contentInsets
        self.cellRegistrar = cellRegistrar
        self.cellFactory = cellFactory
    }

    func registerCellClass(in collectionView: UICollectionView) {
        cellRegistrar(collectionView)
    }

    func makeLayoutItem() -> NSCollectionLayoutItem {
        let size = NSCollectionLayoutSize(widthDimension: width, heightDimension: height)
        let supplementaryItems = [NSCollectionLayoutSupplementaryItem]()
        "TODO: Figure out how to express supplementaryItems"
        let item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: supplementaryItems)
        if let edgeSpacing {
            item.edgeSpacing = edgeSpacing
        }
        if let contentInsets {
            item.contentInsets = contentInsets
        }
        return item
    }

    func makeCell(with value: ItemValue, for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        cellFactory(collectionView, indexPath, value)
    }
}


// MARK: - Cell + ReusableViewConfigurable

public typealias CellConfigurable = UICollectionViewCell & ReusableViewConfigurable

public extension Cell {

    init<CellClass: CellConfigurable>(
        _ cellClass: CellClass.Type,
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil)
    where ItemValue == CellClass.Value {
        let reuseIdentifier = "\(CellClass.self) \(UUID().uuidString)"
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, value: ItemValue) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellClass
            cell.configure(using: value)
            return cell
        }
        let cellRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(CellClass.self, forCellWithReuseIdentifier: reuseIdentifier)
        }
        self.init(
            width: width,
            height: height,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            cellFactory: cellFactory)
    }
}


extension Cell {

    typealias BodyFactory = (AnyPublisher<ItemValue, Never>) -> UIView

    init(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        body bodyFactory: @escaping BodyFactory)
    {
        let cellClass = ValuePublishingCell<ItemValue>.self
        let reuseIdentifier = "\(cellClass.self) \(UUID().uuidString)"
        let cellRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
        }
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, itemValue: ItemValue) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<ItemValue>
            if cell.bodyFactory == nil {
                cell.bodyFactory = bodyFactory
            }
            cell.configure(using: itemValue)
            return cell
        }
        self.init(
            width: width,
            height: height,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            cellFactory: cellFactory)
    }
}


internal final class ValuePublishingCell<ItemValue>: UICollectionViewCell, ReusableViewConfigurable {

    static public var reuseIdentifier: String { objCClassName }

    var bodyFactory: ((AnyPublisher<ItemValue, Never>) -> UIView)?

    private var subject: CurrentValueSubject<ItemValue, Never>?

    private static var objCClassName: String {
        let cString = class_getName(self)
        let name = String(cString: cString)
        return name
    }

//    private var configurator: AnyCellConfigurator {
//        let objCClass: AnyClass? = object_getClass(self)
//        let className = String(cString: class_getName(objCClass!))
//        return ConfigurableCell.factoriesBySubclassNames[className]!
//    }

    func configure(using value: ItemValue) {
        if let subject {
            // Use already created
            subject.send(value)
            return
        }
        // Create subject and body
        self.subject = CurrentValueSubject(value)
        guard let bodyFactory, let subject else {
            preconditionFailure("Misconfigured cell")
        }
        let publisher = subject.eraseToAnyPublisher()
        let body = bodyFactory(publisher)

        self.contentView.addSubview(body)
        body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            body.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            body.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            body.topAnchor.constraint(equalTo: contentView.topAnchor),
            body.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                .priority(.almostRequired),
        ])
    }
}
