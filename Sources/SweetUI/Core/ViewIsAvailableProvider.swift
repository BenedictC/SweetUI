import Foundation
import Combine


// MARK: - ViewIsAvailableProvider

public protocol ViewIsAvailableProvider: AnyObject {

    typealias ViewIsAvailableHandler = () -> (AnyCancellable?)

    func addViewIsAvailableHandler(withIdentifier identifier: AnyHashable, _ handler: @escaping ViewIsAvailableHandler)
    func removeViewIsAvailableHandler(forIdentifier identifier: AnyHashable)
}



// MARK: _ViewIsAvailableProviderImplementation (Internal)

protocol _ViewIsAvailableProviderImplementation: ViewIsAvailableProvider {

    var viewIsAvailableProviderStorage: ViewIsAvailableProviderStorage { get }
}


class ViewIsAvailableProviderStorage {

    var handlersByIdentifier = [AnyHashable:ViewIsAvailableProvider.ViewIsAvailableHandler]()
    var cancellationsByIdentifier: [AnyHashable: Any]? = nil
}


extension _ViewIsAvailableProviderImplementation {

    var hasViewAvailabilityCancellables: Bool { viewIsAvailableProviderStorage.cancellationsByIdentifier != nil }

    public func addViewIsAvailableHandler(withIdentifier identifier: AnyHashable = UUID(), _ handler: @escaping ViewIsAvailableProvider.ViewIsAvailableHandler) {
        viewIsAvailableProviderStorage.handlersByIdentifier[identifier] = handler
        // Establish and store the connection if ready (connectionCancellationsByIdentifier will be nil if not ready)
        viewIsAvailableProviderStorage.cancellationsByIdentifier?[identifier] = handler()
    }

    public func removeViewIsAvailableHandler(forIdentifier identifier: AnyHashable) {
        viewIsAvailableProviderStorage.cancellationsByIdentifier?.removeValue(forKey: identifier)
        viewIsAvailableProviderStorage.handlersByIdentifier.removeValue(forKey: identifier)
    }

    func updateViewIsAvailableHandlers(isAvailable: Bool) {
        viewIsAvailableProviderStorage.cancellationsByIdentifier = nil
        if isAvailable {
            viewIsAvailableProviderStorage.cancellationsByIdentifier = [:]
            let handlers = viewIsAvailableProviderStorage.handlersByIdentifier
            var fresh = [AnyHashable: Any]()
            for (identifier, handler) in handlers {
                fresh[identifier] = handler()
            }
            for (identifier, cancellations) in (viewIsAvailableProviderStorage.cancellationsByIdentifier ?? [:]) {
                fresh[identifier] = cancellations
            }
            viewIsAvailableProviderStorage.cancellationsByIdentifier = fresh
        }
    }
}
