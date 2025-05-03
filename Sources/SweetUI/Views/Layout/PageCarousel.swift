import UIKit
import Combine


public final class PageCarousel: UIView {

    // MARK: Properties

    public var pages: [UIView] {
        didSet { updatePagesStack() }
    }
    public let spacing: CGFloat
    public let inset: CGFloat
    public let alignment: HStack.Alignment
    public private(set) var selectedPageIndex: Int?
    public var selectedItem: UIView? { selectedPageIndex.flatMap { pages[$0] } }

    private var cancellable: AnyCancellable!
    private var selectedPageIndexSubject: AnySubject<Int, Never>?


    // MARK: Views

    private lazy var pagesStack = HStack(distribution: .fillEqually, alignment: alignment, spacing: 0)

    private lazy var scrollView = CarouselScrollView(axes: .horizontal, delegate: self) {
        pagesStack
    }
        .showsHorizontalScrollIndicator(false)
        .pagingEnabled(true)
        .scrollEnabled(false)
        .clipsToBounds(false)


    // MARK: Instance life cycle

    public init(spacing: CGFloat = 0, inset: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedPageIndex: some Publisher<Int, Never>, @ArrayBuilder<UIView> pages pagesBuilder: () -> [UIView]) {
        let pages = pagesBuilder()
        self.pages = pages
        self.spacing = spacing
        self.inset = inset
        self.alignment = alignment
        super.init(frame: .zero)
        updatePagesStack()

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

        // Subscribe after the view has been built otherwise the initial value won't configure the view
        cancellable = selectedPageIndex.sink { [weak self] index in
            let isIndexValid = index > -1 && index < pages.count
            if isIndexValid {
                self?.selectedPageIndex = index
                if let scrollView = self?.scrollView, !scrollView.isTracking {
                    self?.setContentOffsetToShowPage(at: index, animated: true)
                }
            }
        }
    }

    public convenience init(spacing: CGFloat = 0, inset: CGFloat = 0, alignment: HStack.Alignment = .fill, selectedPageIndex: some Subject<Int, Never>, @ArrayBuilder<UIView> pages pagesBuilder: () -> [UIView]) {
        let publisher = selectedPageIndex.eraseToAnyPublisher()
        self.init(spacing: spacing, inset: inset, alignment: alignment, selectedPageIndex: publisher, pages: pagesBuilder)

        self.selectedPageIndexSubject = selectedPageIndex.eraseToAnySubject()
        self.scrollView.isScrollEnabled = true
        self.scrollView.touchesDidEndHandler = { [weak self] in
            self?.setSelectedPageIndexFromCurrentPage(alwaysSend: true)
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: View life cycle

    private func updatePagesStack() {
        for stale in pagesStack.arrangedSubviews { stale.removeFromSuperview() }

        let paddedPages = pages.map { $0.padding(leading: spacing) }
        for page in paddedPages {
            pagesStack.addArrangedSubview(page)
        }
        NSLayoutConstraint.activate(
            pages.map {
                $0.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -spacing)
            }
        )
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        setContentOffsetToShowPage(at: selectedPageIndex, animated: false)
    }


    // MARK: Event handling

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Point can be outside of the self's bounds, which is surprising.
        let isInBounds = bounds.contains(point)
        return isInBounds ? scrollView : nil
    }
}


// MARK: - Offset management

private extension PageCarousel {

    // This does not set selectedItemIndex
    func setContentOffsetToShowPage(at pageIndex: Int?, animated: Bool) {
        guard let pageIndex, pageIndex > -1, pageIndex < pages.count else { return }
        guard window != nil else { return }

        scrollView.layoutIfNeeded()
        let page = pages[pageIndex]
        let paddedPage = page.superview ?? page // Default should never be needed
        let offset = paddedPage.convert(paddedPage.bounds.origin, to: scrollView)
        scrollView.setContentOffset(offset, animated: animated)
    }

    func indexOfCurrentPage() -> Int? {
        let center = self.center
        let pair = pages.enumerated().first {
            let (_, page) = $0
            let frameInSelfSpace = page.convert(page.bounds, to: self)
            let result = center.x >= frameInSelfSpace.minX && center.x < frameInSelfSpace.maxX
            return result
        }
        return pair?.offset
    }

    func setSelectedPageIndexFromCurrentPage(alwaysSend: Bool = false) {
        guard let selectedPageIndexSubject else {
            return
        }
        if let pageIndex = indexOfCurrentPage() {
            let hasChanged = selectedPageIndex != pageIndex
            if hasChanged || alwaysSend {
                selectedPageIndexSubject.send(pageIndex)
            }
        }
    }
}


// MARK: - UIScrollViewDelegate

extension PageCarousel: UIScrollViewDelegate {

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setSelectedPageIndexFromCurrentPage()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setSelectedPageIndexFromCurrentPage()
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
