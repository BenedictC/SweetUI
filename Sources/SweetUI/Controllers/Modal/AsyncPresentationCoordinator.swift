import UIKit


@MainActor
enum AsyncPresentationCoordinators {

    private static let coordinatorsByPresentedViewController = NSMapTable<UIViewController, AnyObject>.weakToStrongObjects()

    static func createCoordinator<Modal: Presentable>(for modal: Modal) -> AsyncPresentationCoordinator<Modal.Success> {
        let coordinator = AsyncPresentationCoordinator(presented: modal)
        coordinatorsByPresentedViewController.setObject(coordinator, forKey: modal)
        return coordinator
    }

    static func destroyCoordinator(for modal: UIViewController) {
        coordinatorsByPresentedViewController.removeObject(forKey: modal)
    }

    static func coordinator<Success>(for modal: UIViewController, successType: Success.Type) -> AsyncPresentationCoordinator<Success>? {
        var modalRoot = modal
        while let parent = modalRoot.parent {
            modalRoot = parent
        }
        guard let object = coordinatorsByPresentedViewController.object(forKey: modalRoot) else {
            return nil
        }
        guard let coordinator = object as? AsyncPresentationCoordinator<Success> else {
            // Probably means we're dealing with a childVC in that has a different Success to its container
            return nil
        }
        return coordinator
    }

    static func erasedCoordinator(for modal: UIViewController) -> ErasedAsyncPresentationCoordinator? {
        var modalRoot = modal
        while let parent = modalRoot.parent {
            modalRoot = parent
        }
        guard let object = coordinatorsByPresentedViewController.object(forKey: modalRoot) else {
            return nil
        }
        guard let coordinator = object as? ErasedAsyncPresentationCoordinator else {
            assertionFailure()
            return nil
        }
        return coordinator
    }
}


// MARK: -

@MainActor
protocol ErasedAsyncPresentationCoordinator {
    func presentationDidEnd(for viewController: UIViewController)
    func endPresentation(with error: Error, animated: Bool)
}


@MainActor
final class AsyncPresentationCoordinator<Success>: ErasedAsyncPresentationCoordinator {

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
            AsyncPresentationCoordinators.destroyCoordinator(for: presented)
        }
    }
}


// MARK: - Modal

extension AsyncPresentationCoordinator {

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
extension AsyncPresentationCoordinator {

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

extension AsyncPresentationCoordinator {

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
