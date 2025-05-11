import UIKit


public struct SectionHeader<SectionIdentifier>: BoundarySupplement {

    // MARK: - Properties

    let elementKind = UICollectionView.elementKindSectionHeader
    private let viewRegistrar: (UICollectionView) -> Void
    private let viewFactory: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView


    // MARK: - Instance life cycle

    init(
        viewRegistrar: @escaping (UICollectionView) -> Void,
        viewFactory: @escaping (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView
    ) {
        self.viewRegistrar = viewRegistrar
        self.viewFactory = viewFactory
    }


    // MARK: - BoundarySupplement

    public func registerReusableViews(in collectionView: UICollectionView) {
        viewRegistrar(collectionView)
    }

    public func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, indexPath: IndexPath, value: SectionIdentifier) -> UICollectionReusableView? {
        guard elementKind == self.elementKind else { return nil }
        return viewFactory(collectionView, indexPath, value)
    }
}


// MARK: - Published

public extension SectionHeader {

    init(
        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping (OneWayBinding<SectionIdentifier>) -> UIView
    ) {
        typealias CellType = ValuePublishingCell<SectionIdentifier>
        let elementKind = self.elementKind
        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
        self.viewRegistrar = { collectionView in
            collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, sectionIdentifier in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
            cell.initialize(
                bindingOptions: bindingOptions,
                bodyProvider: { cell, publisher in
                    contentBuilder(publisher)
                }
            )
            cell.configure(withValue: sectionIdentifier)
            return cell
        }
    }
}


// MARK: - Content

public extension SectionHeader {

    init<Content: UIView>(
        bindingOptions: BindingOptions = .default,
        contentBuilder: @escaping (_ existing: Content?, _ sectionIdentifier: SectionIdentifier) -> Content
    ) {
        typealias CellType = ContentCell<Content>
        let elementKind = self.elementKind
        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
        self.viewRegistrar = { collectionView in
            collectionView.register(CellType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        self.viewFactory = { collectionView, indexPath, sectionIdentifier in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
            cell.replaceContent { _, content in
                contentBuilder(content, sectionIdentifier)
            }
            return cell
        }
    }
}


// MARK: - Static

public extension SectionHeader {

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
