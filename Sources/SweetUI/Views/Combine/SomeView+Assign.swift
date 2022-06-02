import Combine
import UIKit


// MARK: - Core

public extension SomeView {

    func subscribe<T, P: Publisher>(valueAt keyPath: ReferenceWritableKeyPath<Self, T>, to publisher: P) -> AnyCancellable where P.Output == T, P.Failure == Never {
        let cancellable = publisher.sink { self[keyPath: keyPath] = $0 }
        return AnyCancellable(cancellable)
    }
}


// MARK: - ViewConnectionProvider continuous

public extension SomeView {

    func assign<T, P: Publisher, S: ViewConnectionProvider>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, T>, connectionIdentifier: AnyHashable = UUID(), from source: S, _ sourceKeyPath: KeyPath<S, P>) -> Self where P.Output == T, P.Failure == Never {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { view, source in
            view.subscribe(valueAt: destinationKeyPath, to: source[keyPath: sourceKeyPath])
        }
    }

    func assign<U, P: Publisher, T: ViewConnectionProvider>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, U>, connectionIdentifier: AnyHashable = UUID(), from source: T, builder: @escaping (Self, T) -> P) -> Self where P.Output == U, P.Failure == Never {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { view, source in
            let publisher = builder(view, source)
            return view.subscribe(valueAt: destinationKeyPath, to: publisher)
        }
    }
}


// MARK: - ViewModelConnectionProvider continuous

public extension SomeView {

    func assign<T, P: Publisher, S: ViewModelConnectionProvider>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, T>, connectionIdentifier: AnyHashable = UUID(), from source: S, _ sourceKeyPath: KeyPath<S.ViewModel, P>) -> Self where P.Output == T, P.Failure == Never {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { view, source, viewModel in
            view.subscribe(valueAt: destinationKeyPath, to: viewModel[keyPath: sourceKeyPath])
        }
    }

    func assign<U, P: Publisher, T: ViewModelConnectionProvider>(_ destinationKeyPath: ReferenceWritableKeyPath<Self, U>, connectionIdentifier: AnyHashable = UUID(), from source: T, builder: @escaping (Self, T, T.ViewModel) -> P) -> Self where P.Output == U, P.Failure == Never {
        subscribeToConnection(of: source, connectionIdentifier: connectionIdentifier) { view, source, viewModel in
            let publisher = builder(view, source, viewModel)
            return view.subscribe(valueAt: destinationKeyPath, to: publisher)
        }
    }
}


