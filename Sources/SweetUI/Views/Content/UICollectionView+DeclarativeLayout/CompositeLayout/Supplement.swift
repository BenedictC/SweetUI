import UIKit
import Combine


public struct Supplement<ItemIdentifier> {

    let elementKind: String
    let viewRegistrar: (UICollectionView) -> Void
    let viewFactory: (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionReusableView
    let layoutItemFactory: (NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem

    internal init(
        elementKind: String,
        viewRegistrar: @escaping (UICollectionView) -> Void,
        viewFactory: @escaping (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionReusableView,
        layoutItemFactory: @escaping (NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem)
    {
        self.elementKind = elementKind
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
        self.layoutItemFactory = layoutItemFactory
    }

    func itemSupplementaryTemplates() -> [ItemSupplementaryTemplate<ItemIdentifier>] {
        [
            ItemSupplementaryTemplate(
            elementKind: elementKind,
            registerItemSupplementaryViewHandler: viewRegistrar,
            makeItemSupplementaryViewHandler: viewFactory)
        ]
    }

    func makeLayoutSupplementaryItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem {
        layoutItemFactory(defaultSize)
    }
}


public struct ItemSupplementaryTemplate<ItemIdentifier> {

    let elementKind: String
    let registerItemSupplementaryViewHandler: (UICollectionView) -> Void
    let makeItemSupplementaryViewHandler: (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionReusableView

    func registerItemSupplementaryView(in collectionView: UICollectionView) {
        registerItemSupplementaryViewHandler(collectionView)
    }

    func makeItemSupplementaryView(in collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: ItemIdentifier) -> UICollectionReusableView {
        makeItemSupplementaryViewHandler(collectionView, indexPath, itemIdentifier)
    }
}
