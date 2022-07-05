public protocol CollectCancellablesProvider: AnyObject {

    func storeCancellable(_ cancellable: Any, for key: AnyHashable)
    func discardCancellable(for key: AnyHashable)
}


// MARK: - Cancellable

protocol _CollectCancellablesProviderImplementation: CollectCancellablesProvider {
    var collectCancellablesProviderStorage: CollectCancellablesProviderStorage { get }
}


final class CollectCancellablesProviderStorage {
    var cancellationsByIdentifier = [AnyHashable: Any]()
}


extension _CollectCancellablesProviderImplementation {

    public func storeCancellable(_ cancellable: Any, for key: AnyHashable) {
        collectCancellablesProviderStorage.cancellationsByIdentifier[key] = cancellable
    }

    public func discardCancellable(for key: AnyHashable) {
        collectCancellablesProviderStorage.cancellationsByIdentifier.removeValue(forKey: key)
    }
}
