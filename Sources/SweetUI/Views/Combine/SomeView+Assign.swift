import Combine
import UIKit


// MARK: - Core

public extension SomeView {

    func subscribe<T, P: Publisher>(valueAt keyPath: ReferenceWritableKeyPath<Self, T>, to publisher: P) -> AnyCancellable where P.Output == T, P.Failure == Never {
        let cancellable = publisher.sink { self[keyPath: keyPath] = $0 }
        return AnyCancellable(cancellable)
    }
}


// MARK: - ViewIsAvailableProvider continuous

public extension SomeView {

    func assign<T, P: Publisher, S: ViewIsAvailableProvider>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, T>, handlerIdentifier: AnyHashable = UUID(), from source: S, _ sourceKeyPath: KeyPath<S, P>) -> Self where P.Output == T, P.Failure == Never {
        subscribeToViewIsAvailable(of: source, handlerIdentifier: handlerIdentifier) { view, source in
            view.subscribe(valueAt: destinationKeyPath, to: source[keyPath: sourceKeyPath])
        }
    }

    func assign<U, P: Publisher, T: ViewIsAvailableProvider>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, U>, handlerIdentifier: AnyHashable = UUID(), from source: T, builder: @escaping (Self, T) -> P) -> Self where P.Output == U, P.Failure == Never {
        subscribeToViewIsAvailable(of: source, handlerIdentifier: handlerIdentifier) { view, source in
            let publisher = builder(view, source)
            return view.subscribe(valueAt: destinationKeyPath, to: publisher)
        }
    }
}
