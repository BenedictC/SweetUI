import UIKit


/*
 TODO:
 - Add support for wrapping in UINavigationController

 */

// MARK: - Presentable

public enum PresentableError: Error {
    case cancelled
    case missingValue
}


public protocol Presentable: UIViewController {

    associatedtype Success = Void

    func resultForCancelledPresentation() -> Result<Success, Error>

    /// Also see Presentable callbacks:
    // func endPresentation(with result: Result<Success, Error>, animated: Bool)
    // func presentationDidEnd()
}


// MARK: - Presentable callbacks

@MainActor
public extension Presentable where Self: UIViewController {

    func endPresentation(with result: Result<Success, Error>, animated: Bool) {
        // Can we end the presentation with this result? This is the happy path
        if let coordinator = PresentationCoordinators.presentationCoordinator(for: self) {
            coordinator.endPresentation(with: result, animated: animated)
            return
        }
        // If a coordinator with the matching result type can't be found then look for anyCoordinator.
        // This can occur when self is a child of a containerVC (e.g. UINavigationController) and the container is being presented.
        if let coordinator = PresentationCoordinators.anyPresentationCoordinator(for: self) {
            coordinator.endPresentationWithMissingValue(animated: animated)
            return
        }
        // Eek! Something strange has happened
    }

    func presentationDidEnd() {       
        let coordinator = PresentationCoordinators.anyPresentationCoordinator(for: self)
        coordinator?.presentationDidEnd()
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

    func presentationDidEnd() {
        let coordinator = PresentationCoordinators.anyPresentationCoordinator(for: self)
        coordinator?.presentationDidEnd()
    }
}


// MARK: - Presentable default

@MainActor
public extension Presentable {

    func resultForCancelledPresentation() -> Result<Success, Error> {
        return .failure(PresentableError.cancelled)
    }
}


// MARK: - UIViewController integration

// MARK: Modal

@MainActor
public extension UIViewController {

    func present<Modal: Presentable>(_ modal: Modal, animated: Bool) async throws -> Modal.Success {
        let presenting = viewControllerForModalPresentation(rootedAt: self)
        let coordinator = PresentationCoordinators.createPresentationCoordinator(for: modal)
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
        configuration: @MainActor (UISheetPresentationController) -> Void = UIViewController.defaultSheetPresentationConfiguration)
    async throws -> Modal.Success {
        let presenting = self
        let coordinator = PresentationCoordinators.createPresentationCoordinator(for: modal)
        return try await coordinator.beginSheetPresentation(from: presenting, animated: animated, configuration: configuration)
    }
}


@available(iOS 15, *)
public extension UIViewController {

    static func defaultSheetPresentationConfiguration(_ sheet: UISheetPresentationController) -> Void {
        sheet.detents = [.medium(), .large()]
        sheet.largestUndimmedDetentIdentifier = .medium
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        sheet.prefersEdgeAttachedInCompactHeight = true
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
        let coordinator = PresentationCoordinators.createPresentationCoordinator(for: modal)
        return try await coordinator.beginPopoverPresentation(from: presenting, animated: animated, configuration: configuration)
    }
}

