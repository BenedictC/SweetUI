import Combine


public extension SomeView {

    func assign<P: Publisher>(to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output>, from publisher: P, cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store) -> Self where P.Failure == Never {
        let cancellable = publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }


    // MARK: Promote non-optional publisher to optional
    
    func assign<P: Publisher>(to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output?>, from publisher: P, cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store) -> Self where P.Failure == Never {
        let cancellable = publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
