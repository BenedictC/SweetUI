import UIKit
import Combine


public final class Carousel: UIView {

    // MARK: Properties

    public let items: [UIView]
    public let spacing: CGFloat
    public let inset: CGFloat
    public let alignment: HStack.Alignment
    public private(set) var selectedItemIndex: Int?
    public var selectedItem: UIView? { selectedItemIndex.flatMap { items[$0] } }

    private var cancellable: AnyCancellable!
    private var selectedItemIndexSubject: AnySubject<Int?, Never>?


    // MARK: Views

    private lazy var itemsStack = HStack(distribution: .fillEqually, alignment: alignment, spacing: 0) {
        items
            .map { $0.padding(leading: spacing) }
    }

    private lazy var scrollView = CarouselScrollView(axes: .horizontal, delegate: self) {
        itemsStack
    }
        .showsHorizontalScrollIndicator(false)
        .pagingEnabled(true)
        .scrollEnabled(false)
        .clipsToBounds(false)


    // MARK: Instance life cycle

    public init(spacing: CGFloat = 0, inset: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedItemIndex: some Publisher<Int?, Never>, @ArrayBuilder<UIView> items itemsBuilder: () -> [UIView]) {
        let items = itemsBuilder()
        self.items = items
        self.spacing = spacing
        self.inset = inset
        self.alignment = alignment
        super.init(frame: .zero)

        // Configure views
        clipsToBounds = true
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (inset)),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(inset + spacing)),
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: topAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        NSLayoutConstraint.activate(
            items.map {
                $0.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -spacing)
            }
        )

        // Subscribe after the view has been built otherwise the initial value won't configure the view
        cancellable = selectedItemIndex.sink { [weak self] optionalIndex in
            let index = optionalIndex ?? -1
            let isIndexValid = index > -1 && index < items.count
            self?.selectedItemIndex = isIndexValid ? index : nil
            if let scrollView = self?.scrollView, !scrollView.isTracking {
                self?.setContentOffsetToShowItem(at: index, animated: true)
            }
        }
    }

    public convenience init(spacing: CGFloat = 0, inset: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedItemIndex: some Subject<Int?, Never>, @ArrayBuilder<UIView> items itemsBuilder: () -> [UIView]) {
        let publisher = selectedItemIndex.eraseToAnyPublisher()
        self.init(spacing: spacing, inset: inset, alignment: alignment, selectedItemIndex: publisher, items: itemsBuilder)

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

    public override func layoutSubviews() {
        super.layoutSubviews()
        setContentOffsetToShowItem(at: selectedItemIndex, animated: false)
    }


    // MARK: Event handling

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        scrollView
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
        let content = item.superview ?? item
        let offset = content.convert(content.bounds.origin, to: scrollView)
        scrollView.setContentOffset(offset, animated: animated)
    }

    func itemIndexOfCurrentItem() -> Int? {
        let center = self.center
        let pair = items.enumerated().first {
            let (_, item) = $0
            let frameInSelfSpace = item.convert(item.bounds, to: self)
            let result = center.x >= frameInSelfSpace.minX && center.x < frameInSelfSpace.maxX
            return result
        }
        return pair?.offset
    }

    func setSelectedItemIndexFromCurrentItem(alwaysSend: Bool = false) {
        guard let selectedItemIndexSubject else {
            return
        }
        let itemIndex = itemIndexOfCurrentItem()
        let hasChanged = selectedItemIndex != itemIndex
        if hasChanged || alwaysSend {
            selectedItemIndexSubject.send(itemIndex)
        }
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
