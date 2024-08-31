import UIKit


public extension UIViewController {

    func presentModal<Modal: UIViewController>(_ modal: Modal, animated: Bool) async throws {
        let wrapper = _AsyncPresentationContainerViewController(content: modal)
        wrapper.modalPresentationStyle = modal.modalPresentationStyle
        wrapper.modalTransitionStyle = modal.modalTransitionStyle
        _ = try await presentModal(wrapper, animated: animated)
    }

    @available(iOS 15, *)
    func presentSheet<Modal: UIViewController>(
        _ modal: Modal,
        animated: Bool,
        configuration: @MainActor (UISheetPresentationController) -> Void = { UIViewController.defaultSheetPresentationConfiguration($0) })
    async throws {
        let modal: any Presentable = _AsyncPresentationContainerViewController(content: modal)
        _ = try await presentSheet(modal, animated: animated, configuration: configuration)
    }

    func presentPopover<Modal: UIViewController>(
        _ content: Modal,
        animated: Bool,
        configuration: @MainActor (UIPopoverPresentationController) -> Void)
    async throws {
        let modal = _AsyncPresentationContainerViewController(content: content)
        _ = try await presentPopover(modal, animated: animated, configuration: configuration)
    }
}


public final class _AsyncPresentationContainerViewController<T: UIViewController>: ViewController, Presentable {

    let content: T

    init(content: T) {
        self.content = content
        super.init()
        content.willMove(toParent: self)
        _ = self.view // Force load the view
        addChild(content)
    }

    public private(set) lazy var rootView = content.view!
        .ignoresSafeArea(edges: .all)
}


public extension _SomeViewController {
    typealias ModalPresentationContainer = _AsyncPresentationContainerViewController<Self>
}
