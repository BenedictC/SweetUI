import Foundation


@MainActor
public protocol CancellableStorageProvider {

    var cancellableStorage: CancellableStorage { get }
}



// MARK: - CancellableStorageProvider convenience

public extension CancellableStorageProvider {

    func collectCancellables<T>(with key: CancellableStorageKey = .unique(), actions: () -> T) -> T {
        cancellableStorage.collectCancellables(with: key, actions: actions)
    }
}


// MARK: - Cancellable convenience

public extension Cancellable {

    @MainActor
    func store(in provider: CancellableStorageProvider, withKey key: CancellableStorageKey = .unique()) {
        store(in: provider.cancellableStorage, withKey: key)
    }

    @MainActor
    func store(in storage: CancellableStorage, withKey key: CancellableStorageKey = .unique()) {
        let anyCancellable = self as? AnyCancellable ?? AnyCancellable(self)
        storage.storeCancellable(anyCancellable, withKey: key)
    }
}
