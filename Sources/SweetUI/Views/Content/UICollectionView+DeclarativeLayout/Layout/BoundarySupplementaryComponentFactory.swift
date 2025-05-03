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
        bindingOptions: BindingOptions = .default,
        body bodyProvider: @escaping (OneWayBinding<SectionIdentifier>) -> UIView)
    {
        let viewClass = ValuePublishingCell<SectionIdentifier>.self
        let elementKind = Self.elementKind
        let reuseIdentifier = UniqueIdentifier(elementKind).value
        let viewRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<SectionIdentifier>
            view.initialize(bindingOptions: bindingOptions, bodyProvider: { _, publisher in bodyProvider(publisher) })
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
        body bodyProvider: @escaping () -> UIView
    ) {
        let viewClass = ValuePublishingCell<Void>.self
        let elementKind = Self.elementKind
        let reuseIdentifier = UniqueIdentifier(elementKind).value
        let viewRegistrar = { (collectionView: UICollectionView) in
            collectionView.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
        }
        let viewFactory = { (collectionView: UICollectionView, indexPath: IndexPath, sectionIdentifier: Void) -> UICollectionReusableView in
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ValuePublishingCell<Void>
            view.initialize(bindingOptions: .default, bodyProvider: { _, _ in bodyProvider() })
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
