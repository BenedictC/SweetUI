import UIKit


@MainActor
enum PresentationCoordinators {

    private static let presentationCoordinatorByPresentedViewController = NSMapTable<UIViewController, AnyObject>.weakToStrongObjects()

    static func createPresentationCoordinator<Modal: Presentable>(for modal: Modal) -> PresentationCoordinator<Modal.Success> {
        let coordinator = PresentationCoordinator(presented: modal)
        presentationCoordinatorByPresentedViewController.setObject(coordinator, forKey: modal)
        return coordinator
    }

    static func destroyPresentationCoordinator(for modal: UIViewController) {
        presentationCoordinatorByPresentedViewController.removeObject(forKey: modal)
    }

    static func presentationCoordinator<Modal: Presentable>(for modal: Modal) -> PresentationCoordinator<Modal.Success>? {
        guard let object = presentationCoordinatorByPresentedViewController.object(forKey: modal) else {
            return nil
        }
        guard let coordinator = object as? PresentationCoordinator<Modal.Success> else {
            // Probably means we're dealing with a childVC in that has a different Success to its container
            return nil
        }
        return coordinator
    }

    static func anyPresentationCoordinator(for modal: UIViewController) -> AnyPresentationCoordinator? {
        var modalRoot = modal
        while let parent = modalRoot.parent {
            modalRoot = parent
        }
        guard let object = presentationCoordinatorByPresentedViewController.object(forKey: modalRoot) else {
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
    func presentationDidEnd(for viewController: UIViewController)
    func endPresentation(with error: Error, animated: Bool)
}


@MainActor
final class PresentationCoordinator<Success>: AnyPresentationCoordinator {

    private(set) weak var presented: UIViewController?
    @MainActor
    private var presentationContinuation: CheckedContinuation<Success, Error>?
    private var result: Result<Success, Error>?
    private var continuationResumer: (CheckedContinuation<Success, Error>) -> Void

    init<Presented: Presentable>(presented: Presented) where Presented.Success == Success {
        self.presented = presented
        self.continuationResumer = { continuation in
            presented.fulfilContinuationForCancelledPresentation(continuation)
        }
    }

    func endPresentation(with result: Result<Success, Error>, animated: Bool) {
        self.result = result
        presented?.presentingViewController?.dismiss(animated: animated)
    }

    // Called when endPresentation(with:animated:) is called by a Presentable that's nested in a container. This means the the container is dismissed.
    func endPresentation(with error: Error, animated: Bool) {
        self.result = .failure(error)
        presented?.presentingViewController?.dismiss(animated: animated)
    }

    func presentationDidEnd(for viewController: UIViewController) {
        let isModalRoot = viewController.parent == nil
        let isBeingPresented = viewController.isBeingPresented // Because another full screen modal could have been presented on-top
        guard isModalRoot, !isBeingPresented,
              let presentationContinuation else {
            return // Continuation must have already been completed
        }
        self.presentationContinuation = nil
        // If we don't have a result then the presented VC must fulfil it
        guard let result else {
            continuationResumer(presentationContinuation)
            return
        }
        //
        presentationContinuation.resume(with: result)
        if let presented {
            PresentationCoordinators.destroyPresentationCoordinator(for: presented)
        }
    }
}


// MARK: - Modal

extension PresentationCoordinator {

    func beginPresentation(from presenting: UIViewController, animated: Bool) async throws -> Success {
        guard let presented else {
            fatalError()
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.presentationContinuation = continuation
            presenting.present(presented, animated: animated)
        }
    }
}


// MARK: - Sheet

@available(iOS 15.0, *)
extension PresentationCoordinator {

    func beginSheetPresentation(from presenting: UIViewController, animated: Bool, configuration: @MainActor (UISheetPresentationController) -> Void) async throws -> Success {
        guard let presented else {
            fatalError("Misconfigured PresentationCoordinator. self.modal must contain a value when presentation begins.")
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.presentationContinuation = continuation
            if let sheet = presented.sheetPresentationController {
                configuration(sheet)
            }
            presenting.present(presented, animated: animated)
        }
    }
}


// MARK: - Popover

extension PresentationCoordinator {

    func beginPopoverPresentation(from presenting: UIViewController, animated: Bool, configuration: @MainActor (UIPopoverPresentationController) -> Void) async throws -> Success {
        guard let presented else {
            fatalError("Misconfigured PresentationCoordinator. self.modal must contain a value when presentation begins.")
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.presentationContinuation = continuation
            presented.modalPresentationStyle = .popover
            if let popover = presented.popoverPresentationController {
                configuration(popover)
            }
            presenting.present(presented, animated: animated)
        }
    }
}
