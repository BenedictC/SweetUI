import UIKit


public protocol DecorationComponent {

    var elementKind: String { get }

    func registerDecorationView(in layout: UICollectionViewLayout)
    func makeLayoutDecorationItem() -> NSCollectionLayoutDecorationItem
}
