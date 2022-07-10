import Combine
import UIKit


// MARK: - Core

public extension SomeView where Self: UIControl {

    func subscribeTo(_ event: UIControl.Event, handler: @escaping () -> Void) -> AnyCancellable {
        let actionHandler = ActionHandler<Self>(handler: { _, _ in
            handler()
        })
        return addTarget(with: actionHandler, for: event)
    }

    func subscribeTo(_ event: UIControl.Event, handler: @escaping (Self) -> Void) -> AnyCancellable {
        let actionHandler = ActionHandler<Self>(handler: { control, _ in
            handler(control)
        })
        return addTarget(with: actionHandler, for: event)
    }

    func subscribeTo(_ event: UIControl.Event, handler: @escaping (Self, UIControl.Event) -> Void) -> AnyCancellable {
        let actionHandler = ActionHandler<Self>(handler: { control, event in
            handler(control, event)
        })
        return addTarget(with: actionHandler, for: event)
    }
}


private extension SomeView where Self: UIControl {

    func addTarget(with actionHandler: ActionHandler<Self>, for event: UIControl.Event) -> AnyCancellable {
        addTarget(actionHandler, action: actionHandler.handleEventSelector, for: event)

        return AnyCancellable { [weak self] in
            self?.removeTarget(actionHandler, action: actionHandler.handleEventSelector, for: event)
        }
    }
}


// MARK: - ViewIsAvailableProvider

public extension SomeView where Self: UIControl {

    func on<T: ViewIsAvailableProvider>(
        withHandlerIdentifier identifier: AnyHashable = UUID(),
        _ event: UIControl.Event,
        with provider: T,
        _ handler: @escaping (Self, T) -> Void
    ) -> Self {
        subscribeToViewIsAvailable(withHandlerIdentifier: identifier, from: provider) { control, onConnectProvider in
            let actionHandler = ActionHandler<Self>(handler: { _, _ in
                handler(control, onConnectProvider)
            })
            return control.addTarget(with: actionHandler, for: event)
        }
    }

    func on<T: ViewIsAvailableProvider>(
        withHandlerIdentifier identifier: AnyHashable = UUID(),
        _ event: UIControl.Event,
        with provider: T,
        _ handler: @escaping (Self, T, UIControl.Event) -> Void
    ) -> Self {
        subscribeToViewIsAvailable(withHandlerIdentifier: identifier, from: provider) { control, onConnectProvider in
            let actionHandler = ActionHandler<Self>(handler: { _, _ in
                handler(control, onConnectProvider, event)
            })
            return control.addTarget(with: actionHandler, for: event)
        }
    }
}


// MARK: - Cancellable event handlers

private class ActionHandler<Target> {

    typealias Handler = (Target, UIControl.Event) -> Void

    let handleEventSelector = #selector(ActionHandler<Self>.handleEvent(sender:event:))
    let handler: Handler


    init(handler: @escaping Handler) {
        self.handler = handler
    }

    @objc func handleEvent(sender: Any?, event: UIControl.Event) {
        guard let sender = sender as? Target else {
            return
        }
        handler(sender, event)
    }
}


//// MARK: - StatePublisher
//
//public extension UIControl {
//
//    class StatePublisherSink {
//
//        var cancellables = Set<AnyCancellable>()
//
//        static let shared = StatePublisherSink() // For debug purposes, although maybe we can use a singleton to handle dispatch.
//
//        @objc func stateChanged(for sender: Any?) {
//            guard let control = sender as? UIControl else {
//                return
//            }
//            print(control.state)
//        }
//    }
//
//    var statePublisher: AnyPublisher<UIControl.State, Never> {
//        self.addTarget(StatePublisherSink.shared, action: #selector(Arf.stateChanged(for:)), for: .allEvents)
//        let cancellable = self.publisher(for: \.isEnabled).sink { _ in Arf.shared.stateChanged(for: self) }
//        Arf.shared.cancellables.insert(cancellable)
//        return Just(UIControl.State.normal).eraseToAnyPublisher()
//    }
//}
//
