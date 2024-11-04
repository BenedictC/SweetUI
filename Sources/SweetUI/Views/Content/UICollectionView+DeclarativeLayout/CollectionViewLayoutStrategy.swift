import Foundation
import UIKit
import Combine


// MARK: - CollectionViewLayoutStrategy

public protocol CollectionViewLayoutStrategy {

    associatedtype SectionIdentifier: Hashable
    associatedtype ItemValue: Hashable

    func registerReusableViews(in collectionView: UICollectionView, layout: UICollectionViewLayout)
    func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionViewLayout
    func cell(for collectionView: UICollectionView, itemValue: ItemValue, in sectionIdentifier: SectionIdentifier, at indexPath: IndexPath) -> UICollectionViewCell
    func supplementaryView(for collectionView: UICollectionView, elementKind: String, at indexPath: IndexPath, dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemValue>) -> UICollectionReusableView
}


// MARK: - ReusableViewConfigurable

public protocol ReusableViewConfigurable: UICollectionReusableView {

    associatedtype Value = Void

    func configure(using value: Value)
}

public extension ReusableViewConfigurable where Value == Void {

    func configure(using value: Value) {
        // Do nothing
    }
}


// MARK: - BoundarySupplementaryComponent/AnyBoundarySupplementaryComponent

public protocol BoundarySupplementaryComponent {

    associatedtype SectionIdentifier

    var elementKind: String { get }

    func registerSupplementaryView(in collectionView: UICollectionView)
    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem
    func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView
}


public struct AnyBoundarySupplementaryComponent<SectionIdentifier>: BoundarySupplementaryComponent {

    public let elementKind: String
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

    public func registerSupplementaryView(in collectionView: UICollectionView) {
        registerSupplementaryViewHandler(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        makeLayoutBoundarySupplementaryItemHandler()
    }

    public func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
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


// MARK:

public extension BoundarySupplementaryComponentFactory {

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
        let reuseIdentifier = UniqueIdentifier(elementKind).value
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


// MARK:

final class EmptyBoundarySupplementaryViewBody<Value>: UICollectionReusableView, ReusableViewConfigurable {
    // Do nothing
    func configure(using value: Value) { }
}

public extension BoundarySupplementaryComponentFactory {

    static var empty: Self {
        Self.init(EmptyBoundarySupplementaryViewBody<SectionIdentifier>.self)
    }
}


// MARK:

@available(iOS 14, *)
public extension BoundarySupplementaryComponentFactory {

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
        let reuseIdentifier = UniqueIdentifier(elementKind).value
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


// MARK:

public extension BoundarySupplementaryComponentFactory {

    init(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        alignment: NSRectAlignment = Self.defaultAlignment,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool? = nil,
        pinToVisibleBounds: Bool? = nil,
        body bodyFactory: @escaping (OneWayBinding<SectionIdentifier>) -> UIView)
    {
        let viewClass = ValuePublishingCell<SectionIdentifier>.self
        let elementKind = Self.elementKind
        let reuseIdentifier = UniqueIdentifier(elementKind).value
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


// MARK: 

public extension BoundarySupplementaryComponentFactory where SectionIdentifier == Void {

    init(
        width: NSCollectionLayoutDimension = .fractionalWidth(1),
        height: NSCollectionLayoutDimension = .estimated(44),
        alignment: NSRectAlignment = Self.defaultAlignment,
        absoluteOffset: CGPoint = .zero,
        extendsBoundary: Bool? = nil,
        pinToVisibleBounds: Bool? = nil,
        body bodyFactory: @escaping () -> UIView
    ) {
        let viewClass = ValuePublishingCell<Void>.self
        let elementKind = Self.elementKind
        let reuseIdentifier = UniqueIdentifier(elementKind).value
        let viewRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: Void) -> UICollectionReusableView in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<Void>
            view.bodyFactory =  { _ in bodyFactory() }
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

public struct Header<SectionIdentifier>: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    public static var elementKind: String { UICollectionView.elementKindSectionHeader }
    public static var defaultAlignment: NSRectAlignment { .topLeading }
    public var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    public init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }


    public func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
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

    public func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - Footer

public struct Footer<SectionIdentifier>: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    public static var defaultAlignment: NSRectAlignment { .bottomLeading }
    public static var elementKind: String { UICollectionView.elementKindSectionFooter }
    public var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    public init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }
    

    public func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
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

    public func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - LayoutHeader

public struct LayoutHeader: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    public typealias SectionIdentifier = Void

    public static var defaultAlignment: NSRectAlignment { .topLeading }
    public static let elementKind = UniqueIdentifier("Layout Header").value
    public var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    public init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }

    public func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
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

    public func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - LayoutFooter

public struct LayoutFooter: BoundarySupplementaryComponent, BoundarySupplementaryComponentFactory {

    public typealias SectionIdentifier = Void

    public static var defaultAlignment: NSRectAlignment { .bottomLeading }
    public static let elementKind = UniqueIdentifier("Layout Header").value
    public var elementKind: String { Self.elementKind }
    let width: NSCollectionLayoutDimension
    let height: NSCollectionLayoutDimension
    let alignment: NSRectAlignment
    let absoluteOffset: CGPoint
    let extendsBoundary: Bool?
    let pinToVisibleBounds: Bool?
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView

    public init(width: NSCollectionLayoutDimension, height: NSCollectionLayoutDimension, alignment: NSRectAlignment, absoluteOffset: CGPoint, extendsBoundary: Bool?, pinToVisibleBounds: Bool?, viewRegistrar: @escaping (UICollectionView) -> Void, viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView) {
        self.width = width
        self.height = height
        self.alignment = alignment
        self.absoluteOffset = absoluteOffset
        self.extendsBoundary = extendsBoundary
        self.pinToVisibleBounds = pinToVisibleBounds
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }

    public func registerSupplementaryView(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
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

    public func makeSupplementaryView(for collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView {
        viewFactory(collectionView, indexPath, sectionIdentifier)
    }
}


// MARK: - DecorationComponent

public protocol DecorationComponent {

    var elementKind: String { get }

    func registerDecorationView(in layout: UICollectionViewLayout)
    func makeLayoutDecorationItem() -> NSCollectionLayoutDecorationItem
}


// MARK: - Background

public struct Background: DecorationComponent {

    public let elementKind: String
    let zIndex: Int?
    private let viewRegistrar: (UICollectionViewLayout) -> Void

    public init(elementKind: String, zIndex: Int?, viewRegistrar: @escaping (UICollectionViewLayout) -> Void) {
        self.elementKind = elementKind
        self.zIndex = zIndex
        self.viewRegistrar = viewRegistrar
    }

    public func registerDecorationView(in layout: UICollectionViewLayout) {
        viewRegistrar(layout)
    }

    public func makeLayoutDecorationItem() -> NSCollectionLayoutDecorationItem {
        NSCollectionLayoutDecorationItem.background(elementKind: elementKind)
    }
}


public extension Background {

    init<T: UICollectionReusableView>(
        _ viewClass: T.Type,
        elementKind optionalElementKind: String? = nil,
        zIndex: Int? = nil)
    {
        let elementKind = optionalElementKind ?? UniqueIdentifier("Section Background").value
        let viewClass = T.self
        let viewRegistrar = { (layout: UICollectionViewLayout) in
            layout.register(viewClass, forDecorationViewOfKind: elementKind)
        }
        self.init(elementKind: elementKind, zIndex: zIndex, viewRegistrar: viewRegistrar)
    }

    init(
        elementKind optionalElementKind: String? = nil,
        zIndex: Int? = nil,
        bodyFactory: @escaping () -> UIView)
    {
        let elementKind = optionalElementKind ?? UniqueIdentifier("Section Background").value
        let viewClass: AnyClass = ConfigurableBackground.makeSubclass(bodyFactory: bodyFactory)
        let viewRegistrar = { (layout: UICollectionViewLayout) in
            layout.register(viewClass, forDecorationViewOfKind: elementKind)
        }
        self.init(elementKind: elementKind, zIndex: zIndex, viewRegistrar: viewRegistrar)
    }
}


private class ConfigurableBackground: UICollectionReusableView {

    static var classAndBodyFactoryPairs = [(class: AnyClass, factory: () -> UIView)]()

    static func makeSubclass(bodyFactory: @escaping () -> UIView) -> AnyClass {
        let name = UniqueIdentifier("\(ConfigurableBackground.self)").value
        let subclass: AnyClass = objc_allocateClassPair(ConfigurableBackground.self, name, 0)!
        classAndBodyFactoryPairs.append((subclass, bodyFactory))
        return subclass
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeAndConfigureBody()
    }

    private func makeAndConfigureBody() {
        guard let thisClass = object_getClass(self),
        let pair = ConfigurableBackground.classAndBodyFactoryPairs.first(where: { $0.class == thisClass }) else {
            return
        }
        let body = pair.factory()

        body.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(body)
        NSLayoutConstraint.activate([
            body.leftAnchor.constraint(equalTo: self.leftAnchor),
            body.rightAnchor.constraint(equalTo: self.rightAnchor),
            body.topAnchor.constraint(equalTo: self.topAnchor),
            body.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - LayoutBackground

public struct LayoutBackground {

    let view: UIView

    public init(view: () -> UIView) {
        self.view = view()
    }
}


// MARK: - Cell

public struct Cell <ItemValue: Hashable> {

    private let cellFactory: (UICollectionView, IndexPath, ItemValue) -> UICollectionViewCell
    private let cellRegistrar: (UICollectionView) -> Void
    // This only exists to support compositional layout. It's a mildly ugly hack
    private let makeLayoutItemHandler: (_ size: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem

    internal init(
        cellFactory: @escaping (UICollectionView, IndexPath, ItemValue) -> UICollectionViewCell,
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

    func makeCell(with value: ItemValue, for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        cellFactory(collectionView, indexPath, value)
    }
}


// MARK: - Cell + ReusableViewConfigurable

public typealias CellConfigurable = UICollectionViewCell & ReusableViewConfigurable

public extension Cell {

    init<CellClass: CellConfigurable>(
        _ cellClass: CellClass.Type,
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil)
    where ItemValue == CellClass.Value {
        let reuseIdentifier = UniqueIdentifier("\(cellClass.self)").value
        let cellFactory = { (collectionView: UICollectionView, indexPath: IndexPath, value: ItemValue) in
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
            cellFactory: cellFactory)
    }
}


public extension Cell {

    typealias BodyFactory = (OneWayBinding<ItemValue>) -> UIView

    init(
        size: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        body bodyFactory: @escaping BodyFactory)
    {
        let cellClass = ValuePublishingCell<ItemValue>.self
        let reuseIdentifier = UniqueIdentifier("\(cellClass.self)").value
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
            size: size,
            edgeSpacing: edgeSpacing,
            contentInsets: contentInsets,
            cellRegistrar: cellRegistrar,
            cellFactory: cellFactory)
    }
}


internal final class ValuePublishingCell<ItemValue>: UICollectionViewCell, ReusableViewConfigurable, CancellableStorageProvider {

    var bodyFactory: ((OneWayBinding<ItemValue>) -> UIView)?
    
    private var binding: Binding<ItemValue>?
    let cancellableStorage = CancellableStorage()

    func configure(using value: ItemValue) {
        CancellableStorage.push(cancellableStorage)
        defer { CancellableStorage.pop(expected: cancellableStorage) }
        
        if let binding {
            // Use already created
            binding.send(value)
            return
        }
        // Create subject and body
        self.binding = Binding(wrappedValue: value)
        guard let bodyFactory, let binding else {
            preconditionFailure("Misconfigured cell")
        }
        let body = bodyFactory(binding)

        self.contentView.addSubview(body)
        body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            body.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor),
            body.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor),
            body.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            body.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
                .priority(.almostRequired),
        ])
    }
}
