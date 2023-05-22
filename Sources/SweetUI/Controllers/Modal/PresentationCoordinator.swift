import UIKit


@MainActor
enum PresentationCoordinators {

    private static let presentationCoordinatorByPresentedViewController = NSMapTable<UIViewController, AnyObject>.weakToStrongObjects()

    static func createPresentationCoordinator<Modal: Presentable>(for modal: Modal) -> PresentationCoordinator<Modal> {
        let coordinator = PresentationCoordinator(modal: modal)
        presentationCoordinatorByPresentedViewController.setObject(coordinator, forKey: modal)
        return coordinator
    }

    static func destroyPresentationCoordinator(for modal: UIViewController) {
        presentationCoordinatorByPresentedViewController.removeObject(forKey: modal)
    }

    static func presentationCoordinator<Modal: Presentable>(for modal: Modal) -> PresentationCoordinator<Modal>? {
        guard let object = presentationCoordinatorByPresentedViewController.object(forKey: modal) else {
            return nil
        }
        guard let coordinator = object as? PresentationCoordinator<Modal> else {
            assertionFailure()
            return nil
        }
        return coordinator
    }

    static func anyPresentationCoordinator(for modal: UIViewController) -> AnyPresentationCoordinator? {
        guard let object = presentationCoordinatorByPresentedViewController.object(forKey: modal) else {
            return nil
        }
        guard let coordinator = object as? AnyPresentationCoordinator else {
            assertionFailure()
            return nil
        }
        return coordinator
    }
}


// MARK: -

@MainActor
protocol AnyPresentationCoordinator {
    func presentationDidEnd()
}


@MainActor
final class PresentationCoordinator<Modal: Presentable>: AnyPresentationCoordinator {

    typealias ModalResult = Result<Modal.Success, Error>

    private(set) weak var modal: Modal?
    private var continuation: CheckedContinuation<Modal.Success, Error>?
    private var result: ModalResult?

    init(modal: Modal) {
        self.modal = modal
    }

    func endPresentation(with result: ModalResult, animated: Bool) {
        self.result = result
        modal?.presentingViewController?.dismiss(animated: animated)
    }

    func presentationDidEnd() {
        guard
            let modal,
            let continuation
        else {
            fatalError("Misconfigured PresentationCoordinator. self.modal and continuation must contain values when presentation ends.")
        }
        // Get the result
        let result = result ?? modal.resultForCancelledPresentation()
        Task {
            // Pass it back to the waiting present(...) call.
            await MainActor.run {
                "TODO: Release coordinator"
                continuation.resume(with: result)
            }
        }
    }
}


// MARK: - Modal

extension PresentationCoordinator {

    func beginPresentation(from presenting: UIViewController, animated: Bool) async throws -> Modal.Success {
        guard let modal else {
            fatalError()
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            presenting.present(modal, animated: animated)
        }
    }
}


// MARK: - Sheet

@available(iOS 15.0, *)
extension PresentationCoordinator {

    func beginSheetPresentation(from presenting: UIViewController, animated: Bool, configuration: @MainActor (UISheetPresentationController) -> Void) async throws -> Modal.Success {
        guard let modal else {
            fatalError("Misconfigured PresentationCoordinator. self.modal must contain a value when presentation begins.")
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            if let sheet = modal.sheetPresentationController {
                configuration(sheet)
            }
            presenting.present(modal, animated: animated)
        }
    }
}


// MARK: - Popover

extension PresentationCoordinator {

    func beginPopoverPresentation(from presenting: UIViewController, animated: Bool, configuration: @MainActor (UIPopoverPresentationController) -> Void) async throws -> Modal.Success {
        guard let modal else {
            fatalError("Misconfigured PresentationCoordinator. self.modal must contain a value when presentation begins.")
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            modal.modalPresentationStyle = .popover
            if let popover = modal.popoverPresentationController {
                configuration(popover)
            }
            presenting.present(modal, animated: animated)
        }
    }
}
