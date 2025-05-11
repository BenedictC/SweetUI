import UIKit


public struct LayoutHeader: BoundarySupplement {

    // MARK: - Properties

    let elementKind = UniqueIdentifier("LayoutHeader").value
    private let viewRegistrar: (UICollectionView) -> Void
    private let viewFactory: (UICollectionView, IndexPath, Void) -> UICollectionReusableView


    // MARK: - Instance life cycle

    init(
        viewRegistrar: @escaping (UICollectionView) -> Void,
        viewFactory: @escaping (UICollectionView, IndexPath, Void) -> UICollectionReusableView
    ) {
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }


    // MARK: - BoundarySupplement

    public func registerReusableViews(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    public func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, indexPath: IndexPath, value: Void) -> UICollectionReusableView? {
        guard elementKind == self.elementKind else { return nil }
        return viewFactory(collectionView, indexPath, value)
    }
}


// MARK: - Static

public extension LayoutHeader {

    init<Content: UIView>(
        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping () -> Content
    ) {
        typealias CellType = ContentCell<Content>
        let elementKind = self.elementKind
        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
        self.viewRegistrar = { collectionView in
            collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, sectionIdentifier in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
            if !cell.hasContent {
                cell.replaceContent { _, content in
                    contentBuilder()
                }
            }
            return cell
        }
    }
}
