import Foundation


// MARK: - Arf

protocol _ConnectionProviderImplementation: ConnectionProvider {

    var connectionProviderStorage: ConnectionProviderStorage { get }
}


// MARK: - Arf

class ConnectionProviderStorage {

    var handlersByIdentifier = [AnyHashable: ConnectionProvider.ConnectionHandler]()
    var cancellationsByIdentifier: [AnyHashable: Any]? = nil
}


extension _ConnectionProviderImplementation {

    var areConnectionsActive: Bool { connectionProviderStorage.cancellationsByIdentifier != nil }    

    public func addConnectionHandler(withIdentifier identifier: AnyHashable = UUID(), _ handler: @escaping ViewConnectionProvider.ConnectionHandler) {
        connectionProviderStorage.handlersByIdentifier[identifier] = handler
        // Establish and store the connection if ready (connectionCancellationsByIdentifier will be nil if not ready)
        connectionProviderStorage.cancellationsByIdentifier?[identifier] = handler()
    }

    public func removeConnectionHandler(forIdentifier identifier: AnyHashable) {
        connectionProviderStorage.cancellationsByIdentifier?.removeValue(forKey: identifier)
        connectionProviderStorage.handlersByIdentifier.removeValue(forKey: identifier)
    }

    func updateConnectionHandlers(shouldConnect: Bool) {
        connectionProviderStorage.cancellationsByIdentifier = nil
        if shouldConnect {
            connectionProviderStorage.cancellationsByIdentifier = [:]
            let connectionHandlersByIdentifier = connectionProviderStorage.handlersByIdentifier
            for (identifier, handler) in connectionHandlersByIdentifier {
                connectionProviderStorage.cancellationsByIdentifier?[identifier] = handler()
            }
        }
    }
}
