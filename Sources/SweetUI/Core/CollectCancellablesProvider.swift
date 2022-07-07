public protocol CollectCancellablesProvider: AnyObject {

    func storeCancellable(_ cancellable: Any, for key: AnyHashable)
    func discardCancellable(for key: AnyHashable)

    var collectCancellablesProviderStorage: CollectCancellablesProviderStorage { get }
}


// MARK: - Implementation

public final class CollectCancellablesProviderStorage {

    var cancellationsByIdentifier = [AnyHashable: Any]()

    public init() { }
}


extension CollectCancellablesProvider {

    public func storeCancellable(_ cancellable: Any, for key: AnyHashable) {
        collectCancellablesProviderStorage.cancellationsByIdentifier[key] = cancellable
    }

    public func discardCancellable(for key: AnyHashable) {
        collectCancellablesProviderStorage.cancellationsByIdentifier.removeValue(forKey: key)
    }
}
