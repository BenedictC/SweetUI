//import Foundation
//import UIKit
//
//
//// MARK: - CollectionView
//
//public class CollectionView<ItemIdentifier: Hashable, SectionIdentifier: Hashable>: UICollectionView {
//
//    // MARK: Properties
//
//    public var diffableDataSource: UICollectionViewDiffableDataSource<ItemIdentifier, SectionIdentifier>!
//
//
//    // MARK: Instance life cycle
//
//    init(layout: UICollectionViewLayout) {
//        super.init(frame: .zero, collectionViewLayout: layout)
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit {
//        print("CollectionView says bye!")
//    }
//}
//
//
//// MARK: - Init
//
//enum ArfElement<ItemIdentifier: Hashable, SectionIdentifier: Hashable> {
//    case identifierTypes(item: ItemIdentifier.Type, section: SectionIdentifier.Type)
//    case boundaryItem(CollectionViewConfigurationBoundarySupplementaryItem)
//    case section(CollectionViewConfigurationSection<ItemIdentifier, SectionIdentifier>)
//}
//
//extension CollectionView {
//
////    convenience init(configurationBuilder: (CollectionViewConfigurationBuilder<ItemIdentifier, SectionIdentifier>) -> Void) {
////        let builder = CollectionViewConfigurationBuilder<ItemIdentifier, SectionIdentifier>()
////        configurationBuilder(builder)
////        let configuration = builder.configuration
////
////        self.init(layout: configuration.layout)
////
////        self.diffableDataSource = UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, itemIdentifier in
////            fatalError()
////        }
////    }
//
//}
//
//
//// MARK: - CollectionViewConfiguration
//
//class CollectionViewConfiguration<ItemIdentifier: Hashable, SectionIdentifier: Hashable> {
//
//    // MARK: Types
//
//    public typealias Section = CollectionViewConfigurationSection<ItemIdentifier, SectionIdentifier>
//
//
//    // MARK: Properties
//
//    let sections: [Section]
//
//
//    // MARK: Instance life cycle
//
//    init(sections: [Section]) {
//        fatalError()
//    }
//}
//
//
//
//
//
//class CollectionViewConfigurationItem<ItemIdentifier: Hashable> {
//    let identifier: ItemIdentifier
//
//    init(identifier: ItemIdentifier) {
//        self.identifier = identifier
//    }
//}
//
//
//class CollectionViewConfigurationSupplementaryItem {
//
//}
//
//
//class CollectionViewConfigurationBoundarySupplementaryItem {
//
////    init() {
////        NSCollectionLayoutBoundarySupplementaryItem
////        layoutSize: NSCollectionLayoutSize, elementKind: String, alignment: NSRectAlignment, absoluteOffset: CGPoint
////        open var extendsBoundary: Bool
////        open var pinToVisibleBounds: Bool
//
////        NSCollectionLayoutSupplementaryItem
////        layoutSize: NSCollectionLayoutSize, elementKind: String, containerAnchor: NSCollectionLayoutAnchor, itemAnchor: NSCollectionLayoutAnchor)
////        open var zIndex: Int
////    }
//}
//
//
//class CollectionViewConfigurationSection<ItemIdentifier: Hashable, SectionIdentifier: Hashable> {
//
//    let sectionIdentifier: SectionIdentifier
//    let group: CollectionViewConfigurationGroup<ItemIdentifier>
//
//    init(sectionIdentifier: SectionIdentifier, group groupBuilder: () -> CollectionViewConfigurationGroup<ItemIdentifier>) {
//        self.sectionIdentifier = sectionIdentifier
//        self.group = groupBuilder()
//    }
//}
//
//
//class CollectionViewConfigurationGroup<ItemIdentifier: Hashable> {
//
//    let items: [CollectionViewConfigurationItem<ItemIdentifier>]
//
//    init(items itemBuilder: () -> [CollectionViewConfigurationItem<ItemIdentifier>]) {
//        self.items = itemBuilder()
//    }
//}
//
//
//
//// MARK: Factories
//
//extension CollectionViewConfiguration {
//
//    var layout: UICollectionViewCompositionalLayout { fatalError() }
//}
//
//
//class CollectionViewConfigurationBuilder<ItemIdentifier: Hashable, SectionIdentifier: Hashable> {
//
//    var configuration: CollectionViewConfiguration<ItemIdentifier, SectionIdentifier> { fatalError() }
//
//    func header(builder: (CollectionViewConfigurationBoundarySupplementaryItem) -> Void) {
//        let arf = CollectionViewConfigurationBoundarySupplementaryItem()
//        builder(arf)
//    }
//
//    func footer(builder: () -> Void) {
//
//    }
//
//    func section(_ identifier: SectionIdentifier, builder: () -> Void) {
//
//    }
//
//}
//
//
//// MARK: - Example
//
//class ArfCell: CollectionViewCell {
//    let body = UILabel()
//}
//
//struct Foo<ItemIdentifier: Hashable, SectionIdentifier: Hashable> {
//
//    let itemIdentifier: ItemIdentifier
//    let sectionIdentifier: SectionIdentifier
//}
//
//
//
//extension CollectionView {
//
//   convenience init(@FooBuilder<ItemIdentifier, SectionIdentifier> builder: () -> Foo<ItemIdentifier, SectionIdentifier>) {
//        fatalError()
//    }
//}
//
//struct CollectionViewElement<View: UIView> {
//    let viewClass = View.self
//}
//
//
//protocol CollectionViewElements {
//    typealias BoundaryItem = CollectionViewElement
//    typealias Header = CollectionViewElement
//    typealias Footer = CollectionViewElement
//    typealias Background = CollectionViewElement
//
//    typealias Section = CollectionViewElement
//
//}
//
//@resultBuilder
//struct FooBuilder<ItemIdentifier: Hashable, SectionIdentifier: Hashable> {
//
//
//    static func buildBlock(_ components: Any...) -> Foo<ItemIdentifier, SectionIdentifier> {
//        fatalError()
//    }
//
//}
//
//
//class Wgreshd: CollectionViewElements {
//
//    enum SectionIdentifier {
//        case hero, list, carousel
//    }
//
//    enum ItemIdentifier {
//        case standard, double, promo
//    }
//
//    // - Layout
//    // - View
//    // - Data to layout mapping
//    // - Data to view mapping
//    // - View configuration
//
//    lazy var fooBuiltCollectionView = CollectionView<ItemIdentifier, SectionIdentifier> {
//        Background<UIView>()
//        Header<UIView>()
////        Section(SectionIdentifier.grid) {
////            Background<UIView>()
////            Header<UIView>() { /* configure header here */ }
////            Group {
////                Item<ArfCell, ItemIdentifier> { collectionView, cell, item in
////                    cell.value = item
////                }
////                Item<ArfCell> { collectionView, cell, item in
////                    /* configure cell here */
////                }
////            }
////            Footer<UIView>()
////        }
////        SectionProvider<SectionIdentifier> { [weak self] SectionIdentifier, NSCollectionLayoutEnvironment, DataSourceSnapshot in
////
////        }
//        Footer<UIView>()
//    }
//    // - Current:
//    // sectionProvider: (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection?
//    // cellProvider: (_ collectionView: UICollectionView, _ indexPath: IndexPath, _ itemIdentifier: ItemIdentifierType) -> UICollectionViewCell?
//}
//
//
//func collectionView<ItemIdentifier, SectionIdentifier>(_ collectionView: CollectionView<ItemIdentifier, SectionIdentifier>, layoutSectionForSnapshotSectionIndex index: Int, inSnaphot snapshot: NSDiffableDataSourceSnapshot<ItemIdentifier, SectionIdentifier>) -> NSCollectionLayoutSection {
//    let sectionIdentifier = snapshot.sectionIdentifiers[index]
//    return collectionView.configuration.sectionFor(identifier: sectionIdentifier)
//}
//
//
//
////var collectionView = CollectionView<String, String> {
////    $0.header {
////        _ = $0
////    }
////    $0.section("Section 1") {
//////        $0.group {
//////            $0.cell
//////        }
////    }
////    $0.footer() {
////
////    }
////}
//
//
//
//
//// MARK: - The competiton
//
//func makeCollectionViewLayout() -> UICollectionViewLayout {
//    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))
//    let groupSupplementaryItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50))
//    let groupSupplementaryItem = NSCollectionLayoutSupplementaryItem(layoutSize: groupSupplementaryItemSize, elementKind: "group-footer", containerAnchor: NSCollectionLayoutAnchor(edges: .bottom, absoluteOffset: .zero), itemAnchor: NSCollectionLayoutAnchor(edges: .bottom, absoluteOffset: .zero))
//    let group = NSCollectionLayoutGroup(layoutSize: groupSize, supplementaryItems: [groupSupplementaryItem])
//    let section = NSCollectionLayoutSection(group: group)
//
//    let configuration: UICollectionViewCompositionalLayoutConfiguration = {
//        let configuration = UICollectionViewCompositionalLayoutConfiguration()
//        configuration.scrollDirection = .vertical
//        configuration.interSectionSpacing = 0
//        configuration.boundarySupplementaryItems = [] // [NSCollectionLayoutBoundarySupplementaryItem]
//        if #available(iOS 14, *) {
//            configuration.contentInsetsReference = .safeArea //
//        }
//        return configuration
//    }()
//
//    let layout = UICollectionViewCompositionalLayout(section: section, configuration: configuration)
//    return layout
//}
