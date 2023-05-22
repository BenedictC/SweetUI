import UIKit


public extension UIViewController {

    func present<Modal: UIViewController>(_ modal: Modal, animated: Bool) async throws {
        let wrapper = ModalPresentationWrapperViewController(wrapped: modal)
        _ = try await present(wrapper, animated: animated)
    }

    @available(iOS 15, *)
    func presentSheet<Modal: UIViewController>(
        _ modal: Modal,
        animated: Bool,
        configuration: @MainActor (UISheetPresentationController) -> Void = UIViewController.defaultSheetPresentationConfiguration)
    async throws {
        let wrapper: any Presentable = ModalPresentationWrapperViewController(wrapped: modal)
        _ = try await presentSheet(wrapper, animated: animated, configuration: configuration)
    }

    func presentPopover<Modal: UIViewController>(
        _ modal: Modal,
        animated: Bool,
        configuration: @MainActor (UIPopoverPresentationController) -> Void)
    async throws {
        let wrapper = ModalPresentationWrapperViewController(wrapped: modal)
        _ = try await presentPopover(wrapper, animated: animated, configuration: configuration)
    }
}


private final class ModalPresentationWrapperViewController<T: UIViewController>: ViewController, Presentable {

    let wrapped: T

    init(wrapped: T) {
        self.wrapped = wrapped
        super.init()
        wrapped.willMove(toParent: self)
        _ = self.view // Force load the view
        addChild(wrapped)
    }

    private(set) lazy var rootView = wrapped.view!
        .ignoresSafeArea(edges: .all)
}

