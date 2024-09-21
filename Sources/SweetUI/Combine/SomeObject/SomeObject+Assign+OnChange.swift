import Foundation
import Combine


// MARK: - Bind

/// Take a keyPath and return Self
public extension SomeObject {

    @discardableResult
    func assign<P: Publisher>(
        to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output>,
        from publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared,
        cancellableIdentifier: AnyHashable = UUID()
    ) -> Self where P.Failure == Never {
        let cancellable = publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        let storageKey = CancellableStorageKey(object: self, identifier: cancellableIdentifier)
        cancellableStorageProvider.storeCancellable(cancellable, forKey: storageKey)
        return self
    }


    // MARK: Promote non-optional publisher to optional
    
    @discardableResult
    func assign<P: Publisher>(
        to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output?>,
        from publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared,
        cancellableIdentifier: AnyHashable = UUID()
    ) -> Self where P.Failure == Never {
        let cancellable = publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        let storageKey = CancellableStorageKey(object: self, identifier: cancellableIdentifier)
        cancellableStorageProvider.storeCancellable(cancellable, forKey: storageKey)
        return self
    }
}


// MARK: - OnChange

/// Take a closure and return Self
public extension SomeObject {

    @discardableResult
    func onChange<V, P: Publisher>(
        of publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared,
        cancellableIdentifier: AnyHashable = UUID(),
        perform action: @escaping (Self, P.Output) -> Void
    ) -> Self where P.Output == V, P.Failure == Never {
        // We don't need to store action because it's captured in a block is stored
        let cancellable = publisher.sink { [weak self] newValue in
            guard let self else { return }
            action(self, newValue)
        }
        let storageKey = CancellableStorageKey(object: self, identifier: cancellableIdentifier)
        cancellableStorageProvider.storeCancellable(cancellable, forKey: storageKey)
        return self
    }
}
