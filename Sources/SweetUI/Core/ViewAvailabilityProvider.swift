import Foundation
import Combine


// MARK: - ViewAvailabilityProvider

public protocol ViewAvailabilityProvider: AnyObject {

    typealias ViewIsAvailableHandler = () -> (AnyCancellable?)

    func registerForViewAvailability(withIdentifier identifier: AnyHashable, _ handler: @escaping ViewIsAvailableHandler)
    func unregisterViewAvailability(forIdentifier identifier: AnyHashable)
}



// MARK: _ViewAvailabilityProviderImplementation (Internal)

protocol _ViewAvailabilityProviderImplementation: ViewAvailabilityProvider {

    var viewAvailabilityProviderStorage: ViewAvailabilityProviderStorage { get }
}


class ViewAvailabilityProviderStorage {

    var handlersByIdentifier = [AnyHashable:ViewAvailabilityProvider.ViewIsAvailableHandler]()
    var cancellationsByIdentifier: [AnyHashable: Any]? = nil
}


extension _ViewAvailabilityProviderImplementation {

    var hasViewAvailabilityCancellables: Bool { viewAvailabilityProviderStorage.cancellationsByIdentifier != nil }

    public func registerForViewAvailability(withIdentifier identifier: AnyHashable = UUID(), _ handler: @escaping ViewAvailabilityProvider.ViewIsAvailableHandler) {
        viewAvailabilityProviderStorage.handlersByIdentifier[identifier] = handler
        // Establish and store the connection if ready (connectionCancellationsByIdentifier will be nil if not ready)
        viewAvailabilityProviderStorage.cancellationsByIdentifier?[identifier] = handler()
    }

    public func unregisterViewAvailability(forIdentifier identifier: AnyHashable) {
        viewAvailabilityProviderStorage.cancellationsByIdentifier?.removeValue(forKey: identifier)
        viewAvailabilityProviderStorage.handlersByIdentifier.removeValue(forKey: identifier)
    }

    func updateViewIsAvailableHandlers(isAvailable: Bool) {
        viewAvailabilityProviderStorage.cancellationsByIdentifier = nil
        if isAvailable {
            viewAvailabilityProviderStorage.cancellationsByIdentifier = [:]
            let handlers = viewAvailabilityProviderStorage.handlersByIdentifier
            var fresh = [AnyHashable: Any]()
            for (identifier, handler) in handlers {
                fresh[identifier] = handler()
            }
            for (identifier, cancellations) in (viewAvailabilityProviderStorage.cancellationsByIdentifier ?? [:]) {
                fresh[identifier] = cancellations
            }
            viewAvailabilityProviderStorage.cancellationsByIdentifier = fresh
        }
    }
}
