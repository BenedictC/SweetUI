import UIKit


public extension Presentable {

    func embedInNavigationController() -> PresentableNavigationController<Self> {
        PresentableNavigationController(root: self)
    }
}


public class PresentableNavigationController<Root: Presentable>: UINavigationController, Presentable {

    let initialRoot: Root

    init(root: Root) {
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
