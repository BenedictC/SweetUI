import UIKit


// MARK: - Presentable

public enum PresentableError: Error {
    case cancelled
    case presentationEndedFromNestedViewController
}


public protocol Presentable: UIViewController {

    associatedtype Success = Void

    func resultForCancelledPresentation() -> Result<Success, Error>
    func fulfilContinuationForCancelledPresentation(_ continuation: CheckedContinuation<Success, Error>)

    /// Also see Presentable callbacks:
    // func endPresentation(with result: Result<Success, Error>, animated: Bool)
    // func didDisappear()
}


// MARK: - Presentable callbacks

@MainActor
public extension Presentable where Self: UIViewController {

    // This method could be directly on UIViewController but that would encourage unanticipated use of the API.
    func endPresentation(with result: Result<Success, Error>, animated: Bool) {
        // Can we end the presentation with this result? This is the happy path
        if let coordinator = AsyncPresentationCoordinators.coordinator(for: self, successType: Success.self) {
            coordinator.endPresentation(with: result, animated: animated)
            return
        }
        print("Attempted to end presentation from a child of the presented view controller with mismatched Success types. Result will be discarded and replaced with `PresentableError.presentationEndedFromNestedViewController`.")
        if let coordinator = AsyncPresentationCoordinators.erasedCoordinator(for: self) {
            coordinator.endPresentation(with: PresentableError.cancelled, animated: animated)
            return
        }
        print("Attempted to end presentation from a view controller that is not currently involved in an asynchronous presentation. No presentations will be ended.")
    }
 
    func didDisappear() {
        let isModalRoot = self.parent == nil
        let isPresentationFinished = self.presentingViewController == nil
        let shouldInformPresentationCoordinator = isModalRoot && isPresentationFinished
        guard shouldInformPresentationCoordinator else {
            return
        }
        let coordinator = AsyncPresentationCoordinators.erasedCoordinator(for: self)
        coordinator?.presentationDidEnd(for: self)
    }
}


@MainActor
public extension Presentable {

    func cancelPresentation(animated: Bool) {
        endPresentation(with: .failure(PresentableError.cancelled), animated: animated)
    }
}


@MainActor
public extension Presentable where Success == Void {

    func endPresentation(animated: Bool) {
        endPresentation(with: .success(()), animated: animated)
    }
}


/// Allows ViewController to participate in Presentable without conforming to it thus mean subclasses only need to implement the core functionality.
@MainActor
internal extension UIViewController {

    func didDisappear() {
        if self.presentingViewController != nil {
            return
        }
        let coordinator = AsyncPresentationCoordinators.erasedCoordinator(for: self)
        coordinator?.presentationDidEnd(for: self)
    }
}


// MARK: - Presentable default

@MainActor
public extension Presentable {

    func resultForCancelledPresentation() -> Result<Success, Error> {
        return .failure(PresentableError.cancelled)
    }

    func fulfilContinuationForCancelledPresentation(_ continuation: CheckedContinuation<Success, Error>) {
        let result = self.resultForCancelledPresentation()
        continuation.resume(with: result)
    }
}


// MARK: - UIViewController integration

// MARK: Modal

@MainActor
public extension UIViewController {

    func present<Modal: Presentable>(_ modal: Modal, animated: Bool) async throws -> Modal.Success {
        let presenting = viewControllerForModalPresentation(rootedAt: self)
        let coordinator = AsyncPresentationCoordinators.createCoordinator(for: modal)
        return try await coordinator.beginPresentation(from: presenting, animated: animated)
    }

    private func viewControllerForModalPresentation(rootedAt root: UIViewController) -> UIViewController {
        // UIKit seems to perform this same logic so this may not be necessary
        var presenting = root
        while let child = presenting.presentedViewController {
            presenting = child
        }
        return presenting
    }
}


// MARK: Sheet

@available(iOS 15, *)
@MainActor
public extension UIViewController {

    func presentSheet<Modal: Presentable>(
        _ modal: Modal,
        animated: Bool,
        configuration: @MainActor (UISheetPresentationController) -> Void = { UIViewController.defaultSheetPresentationConfiguration($0) })
    async throws -> Modal.Success {
        let presenting = self
        let coordinator = AsyncPresentationCoordinators.createCoordinator(for: modal)
        return try await coordinator.beginSheetPresentation(from: presenting, animated: animated, configuration: configuration)
    }
}


@available(iOS 15, *)
@MainActor
public extension UIViewController {

    static func defaultSheetPresentationConfiguration(_ sheet: UISheetPresentationController) -> Void {
        sheet.detents = [.medium(), .large()]
        sheet.largestUndimmedDetentIdentifier = .medium
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }
}


// MARK: Popover

@MainActor
public extension UIViewController {

    func presentPopover<Modal: Presentable>(
        _ modal: Modal,
        animated: Bool,
        configuration: @MainActor (UIPopoverPresentationController) -> Void)
    async throws -> Modal.Success {
        let presenting = self
        let coordinator = AsyncPresentationCoordinators.createCoordinator(for: modal)
        return try await coordinator.beginPopoverPresentation(from: presenting, animated: animated, configuration: configuration)
    }
}
