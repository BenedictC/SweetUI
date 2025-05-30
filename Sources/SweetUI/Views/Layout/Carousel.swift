import UIKit
import Combine


public final class Carousel: UIView {

    // MARK: Properties

    public var items: [UIView] {
        didSet { updateItemsStack() }
    }
    public let spacing: CGFloat
    public let itemWidth: CGFloat?
    public let inset: CGFloat
    public let alignment: HStack.Alignment
    public private(set) var selectedItemIndex: Int?
    public var selectedItem: UIView? { selectedItemIndex.flatMap { items[$0] } }

    private var cancellable: AnyCancellable!
    private var selectedItemIndexSubject: AnySubject<Int, Never>?
    

    // MARK: Views

    private lazy var itemsStack = HStack(distribution: .fillEqually, alignment: alignment, spacing: 0)

    private lazy var scrollView = CarouselScrollView(axes: .horizontal, delegate: self) {
        itemsStack
    }
        .showsHorizontalScrollIndicator(false)
        .pagingEnabled(true)
        .scrollEnabled(false)
        .clipsToBounds(false)


    // MARK: Instance life cycle

    public init(inset: CGFloat = 0, itemWidth: CGFloat? = nil, spacing: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedItemIndex: some Publisher<Int, Never>, items: [UIView] = []) {
        let items = items
        self.items = items
        self.spacing = spacing
        self.itemWidth = itemWidth
        self.inset = inset
        self.alignment = alignment
        super.init(frame: .zero)

        // Configure views
        clipsToBounds = true
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        if let itemWidth {
            NSLayoutConstraint.activate([
                scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (inset)),
                scrollView.frameLayoutGuide.widthAnchor.constraint(equalToConstant: itemWidth + spacing),
                scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
                scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (inset)),
                scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(inset + spacing)),
                scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
                scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        updateItemsStack()

        // Subscribe after the view has been built otherwise the initial value won't configure the view
        cancellable = selectedItemIndex.sink { [weak self] index in
            let isIndexValid = index > -1 && index < items.count
            if isIndexValid {
                self?.selectedItemIndex = index
                if let scrollView = self?.scrollView, !scrollView.isTracking {
                    self?.setContentOffsetToShowItem(at: index, animated: true)
                }
            }
        }
    }

    public convenience init(inset: CGFloat = 0, itemWidth: CGFloat? = nil, spacing: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedItemIndex: some Subject<Int, Never>, items: [UIView] = []) {
        let publisher = selectedItemIndex.eraseToAnyPublisher()
        self.init(inset: inset, itemWidth: itemWidth, spacing: spacing, alignment: alignment, selectedItemIndex: publisher, items: items)

        self.selectedItemIndexSubject = selectedItemIndex.eraseToAnySubject()
        self.scrollView.isScrollEnabled = true
        self.scrollView.touchesDidEndHandler = { [weak self] in
            self?.setSelectedItemIndexFromCurrentItem(alwaysSend: true)
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: View life cycle

    private func updateItemsStack() {
        for stale in itemsStack.arrangedSubviews { stale.removeFromSuperview() }

        let paddedItems = items.map { $0.padding(leading: spacing) }
        for item in paddedItems {
            itemsStack.addArrangedSubview(item)
        }
        if let itemWidth {
            NSLayoutConstraint.activate(
                items.map {
                    $0.widthAnchor.constraint(equalToConstant: itemWidth)
                }
            )
        } else {
            NSLayoutConstraint.activate(
                items.map {
                    $0.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -spacing)
                }
            )
        }

        adjustScrollViewContentInset()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        setContentOffsetToShowItem(at: selectedItemIndex, animated: false)
        adjustScrollViewContentInset()
    }


    // MARK: Event handling

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Point can be outside of the self's bounds, which is surprising.
        let isInBounds = bounds.contains(point)
        guard isInBounds else { return nil }

        let superResult = super.hitTest(point, with: event)
        if superResult != self {
            return superResult
        }

        // We've messed up the scrollView's hitTest because of clipToBounds and frame manipulations
        // so we manually find its subviews.
        let pointInScrollViewCoordinateSpace = scrollView.convert(point, from: self)
        let hitSubviews: [UIView] = scrollView.subviews
            .filter { $0.frame.contains(pointInScrollViewCoordinateSpace) }
        let zIndexAndSubviewPairs: [(zIndex: Int, subview: UIView)] = hitSubviews.compactMap { subview in
            guard let zIndex = scrollView.subviews.firstIndex(of: subview) else { return nil }
            return (zIndex: zIndex, subview: subview)
        }
        let subviewsByZIndex = Dictionary(uniqueKeysWithValues: zIndexAndSubviewPairs)
        let subview = subviewsByZIndex.keys.max().flatMap { subviewsByZIndex[$0] }
        if let subview {
            let pointInSubviewCoordinateSpace = subview.convert(point, from: self)
            return subview.hitTest(pointInSubviewCoordinateSpace, with: event)
        }
        return scrollView.hitTest(pointInScrollViewCoordinateSpace, with: event)
    }
}


// MARK: - Offset management

private extension Carousel {

    // This does not set selectedItemIndex
    func setContentOffsetToShowItem(at itemIndex: Int?, animated: Bool) {
        guard let itemIndex, itemIndex > -1, itemIndex < items.count else { return }
        guard window != nil else { return }

        scrollView.layoutIfNeeded()
        let item = items[itemIndex]
        let paddedItem = item.superview ?? item // Default should never be needed
        let offset = paddedItem.convert(paddedItem.bounds.origin, to: scrollView)
        scrollView.setContentOffset(offset, animated: animated)
    }

    func indexOfCurrentItem() -> Int? {
        let referenceX = scrollView.contentOffset.x
        for (index, item) in items.enumerated() {
            let paddedItem = item.superview ?? item // Default shouldn't be needed
            let normalizedFrame = paddedItem.convert(paddedItem.bounds, to: scrollView)
            let isFirstVisibleItem = normalizedFrame.minX <= referenceX && normalizedFrame.maxX > referenceX
            if isFirstVisibleItem {
                return index
            }
        }
        return nil
    }

    func setSelectedItemIndexFromCurrentItem(alwaysSend: Bool = false) {
        guard let selectedItemIndexSubject else {
            return
        }
        if let itemIndex = indexOfCurrentItem() {
            let hasChanged = selectedItemIndex != itemIndex
            if hasChanged || alwaysSend {
                selectedItemIndexSubject.send(itemIndex)
            }
        }
    }

    func adjustScrollViewContentInset() {
        // TODO: adjust inset so that the last page doesn't have trailing whitespace
    }
}


// MARK: - UIScrollViewDelegate

extension Carousel: UIScrollViewDelegate {

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setSelectedItemIndexFromCurrentItem()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectedItemIndexFromCurrentItem()
    }
}


// MARK: - CarouselScrollView

private class CarouselScrollView<Content: UIView>: ScrollView<Content> {

    var touchesDidEndHandler: (() -> Void)?

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesDidEndHandler?()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesDidEndHandler?()
    }
}


// MARK: - Factories

public extension Carousel {

    convenience init(inset: CGFloat = 0, itemWidth: CGFloat? = nil, spacing: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedItemIndex: some Publisher<Int, Never>, @SubviewsBuilder items itemsBuilder: () -> [UIView]) {
        self.init(inset: inset, itemWidth: itemWidth, spacing: spacing, alignment: alignment, selectedItemIndex: selectedItemIndex, items: itemsBuilder())
    }

    convenience init(inset: CGFloat = 0, itemWidth: CGFloat? = nil, spacing: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedItemIndex: some Subject<Int, Never>, @SubviewsBuilder items itemsBuilder: () -> [UIView]) {
        self.init(inset: inset, itemWidth: itemWidth, spacing: spacing, alignment: alignment, selectedItemIndex: selectedItemIndex, items: itemsBuilder())
    }
}
