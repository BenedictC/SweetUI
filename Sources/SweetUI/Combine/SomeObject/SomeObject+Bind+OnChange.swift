import Foundation
import Combine


// MARK: - Bind

/// Take a keyPath and return Self
public extension SomeObject {

    func bind<P: Publisher>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output>, to publisher: P, cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store) -> Self where P.Failure == Never {
        let cancellable = publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }


    // MARK: Promote non-optional publisher to optional
    
    func bind<P: Publisher>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output?>, to publisher: P, cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store) -> Self where P.Failure == Never {
        let cancellable = publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


// MARK: - OnChange

/// Take a closure and return Self
public extension SomeObject {

    func onChange<V, P: Publisher>(
        of publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store,
        perform action: @escaping (Self, P.Output) -> Void
    ) -> Self where P.Output == V, P.Failure == Never {
        // We don't need to store action because it's captured in a block is stored
        let cancellable = publisher.sink { [weak self] newValue in
            guard let self else { return }
            action(self, newValue)
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
