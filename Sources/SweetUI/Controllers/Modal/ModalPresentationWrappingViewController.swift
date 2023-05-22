import UIKit


final class ModalPresentationWrapperViewController<T: UIViewController>: ViewController, Presentable {

    let wrapped: T

    init(wrapped: T) {
        self.wrapped = wrapped
        super.init()
    }

    private(set) lazy var rootView = wrapped.view!
        .ignoresSafeArea(edges: .all)
}



open class NavigationController<Root: Presentable>: UINavigationController, Presentable {

    public let initialRoot: Root

    public init(root: Root) {
        self.initialRoot = root
        super.init(rootViewController: root)
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func resultForCancelledPresentation() -> Result<Root.Success, Error> {
        initialRoot.resultForCancelledPresentation()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presentationDidEnd()
    }
}
