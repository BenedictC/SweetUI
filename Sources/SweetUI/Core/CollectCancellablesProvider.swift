import Combine

public protocol CollectCancellablesProvider: AnyObject {

    func storeCancellable<C: Cancellable>(_ cancellable: C, for key: AnyHashable)
    func discardCancellable(for key: AnyHashable)

    var collectCancellablesProviderStorage: CollectCancellablesProviderStorage { get }
}


// MARK: - Implementation

public final class CollectCancellablesProviderStorage {

    var cancellationsByIdentifier = [AnyHashable: AnyCancellable]()

    public init() { }
}


extension CollectCancellablesProvider {

    public func storeCancellable<C: Cancellable>(_ cancellable: C, for key: AnyHashable) {
        let anyCancellable: AnyCancellable
        if let cancellable = cancellable as? AnyCancellable {
            anyCancellable = cancellable
        } else {
            anyCancellable = AnyCancellable(cancellable)
        }
        collectCancellablesProviderStorage.cancellationsByIdentifier[key] = anyCancellable
    }

    public func discardCancellable(for key: AnyHashable) {
        collectCancellablesProviderStorage.cancellationsByIdentifier.removeValue(forKey: key)
    }
}
