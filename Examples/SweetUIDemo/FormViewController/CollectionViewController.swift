import UIKit
import SweetUI
import Combine

/*
 - Section:
    - Other supplementary views
    - background/decoration
    - Custom Header and Footer cells
    - First item as header
    - Different cells based on predicate

 - Root:
    - Header/Footer
    - Decoration

 - Group:
    - Multiple items (with predicate)

 - Cell:
    - Supplementary items

 */

class CollectionViewController: ViewController {

    struct Item: Hashable {
        let section: String
        let value: Int
    }

    @CollectionViewDataSource var items: NSDiffableDataSourceSnapshot<String, Item>

    lazy var rootView = UICollectionView(dataSource: $items) {
        ListLayout(appearance: .sidebar) {
//        LayoutHeader { _ in
//            UILabel()
//                .text("Layout Header")
//        }
            //            LayoutFooter { _ in
            //                UILabel()
            //                    .text("Layout Footer")
            //            }

            // ListSectionWithStandardHeader<String, Int> {
            // ListSectionWithCollapsableHeader<String, Int> {

            ListSectionWithStandardHeader(identifier: "Foo") {
                Header<String> { cell, value in
                    var config = cell.defaultContentConfiguration()
                    config.text = value
                    cell.contentConfiguration = config
                }
                Cell<Item> { cell, item in
                    var configuration = cell.defaultContentConfiguration()
                    configuration.text = "\(item.value)"
                    cell.contentConfiguration = configuration
                }
            }

            ListSectionWithStandardHeader {
                Header<String> { cell, value in
                    var config = cell.defaultContentConfiguration()
                    config.text = value
                    cell.contentConfiguration = config
                }
                Cell<Item> { cell, item in
                    var configuration = cell.defaultContentConfiguration()
                    configuration.text = "\(item.value)"
                    cell.contentConfiguration = configuration
                }
                Footer<String>(DemoCell.self)
            }
        }
    }

//    lazy var rootView = UICollectionView(snapshot: $items) {
//        ComposableLayout {
//            Section<String, Int>(
//                identifier: "Foo")
//            {
//                Header<String> { cell, sectionIdentifier in
//                    var configuration = cell.defaultContentConfiguration()
//                    configuration.text = "\(sectionIdentifier)!!!"
//                    cell.contentConfiguration = configuration
//                }
//                Group<Int>(
//                    axis: .vertical,
//                    width: .fractionalWidth(0.5))
//                {
//                    Cell { (publisher: AnyPublisher<Int, Never>) in
//                        UILabel()
//                            //.frame(height: 88)
//                            .onChange(of: publisher) { label, value in
//                                label.text = "\(value)"
//                                label.textColor = value.isMultiple(of: 2) ? .red : .blue
//                            }
//                            .padding(.vertical(8))
//                    }
//                }
//                Footer<String>()
//            }
//        }
//    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        beginGrowingSnapshot()
        //createExpandableSnapshot()
        //createMultiSectionSnapshot()
    }

    func createMultiSectionSnapshot() {
        var fresh = items
        let sections = ["Foo"] //, "Bar", "Arf"]
        fresh.appendSections(sections)
        for section in sections {
            let items = (0..<10)
                .map { Item(section: section, value: $0) }
            fresh.appendItems(items, toSection: section)
        }
        items = fresh
    }

    func createExpandableSnapshot() {
//        var fresh = items
//        fresh.appendSections(["Foo"])
//        items = fresh
//
//        for sectionIndex in 1..<10 {
//            let sectionIdentifier = "\(sectionIndex)"
//            // 1
//            // Create a section snapshot
//            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Int>()
//            // 2
//            // Create a header ListItem & append as parent
//            sectionSnapshot.append([sectionIndex])
//
//            // 3
//            // Create an array of symbol ListItem & append as child of headerListItem
//            let symbolListItemArray = Array(0..<10).map { $0 + (sectionIndex * 10) }
//            sectionSnapshot.append(symbolListItemArray, to: sectionIndex)
//
//            // 4
//            // Expand this section by default
//            sectionSnapshot.collapse([sectionIndex])
//
//            // 5
//            $items.dataSource?.apply(sectionSnapshot, to: sectionIdentifier, animatingDifferences: false)
//        }
    }


    func beginGrowingSnapshot() {
        var fresh = items
        fresh.appendSections(["Foo"])
        items = fresh

        collectCancellables {
            Timer.publish(every: 2, on: .main, in: .default)
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .sink {
                    var fresh = self.items
                    let value = Item(section: "Foo", value: Int($0.timeIntervalSince1970))
                    if fresh.itemIdentifiers.contains(value) {
                        print("🤪 Skipping duplicate item.")
                        return
                    }
                    if let other = fresh.itemIdentifiers.randomElement() {
                        fresh.insertItems([value], afterItem: other)
                    }else {
                        fresh.appendItems([value], toSection: "Foo")
                    }
                    self.items = fresh
                }
        }
    }
}


final class DemoCell<Value>: CollectionViewCell, ReusableViewConfigurable {

    let body = UILabel()
        .textColor(.green)

    func configure(using value: Value) {
        body.text = "\(value)"
    }
}
