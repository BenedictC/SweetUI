import Combine
import UIKit


public extension SomeView {

    func assign<T, P: Publisher, S: ViewIsAvailableProvider>(
        withHandlerIdentifier identifier: AnyHashable = UUID(),
        to destinationKeyPath: ReferenceWritableKeyPath<Self, T>,
        from provider: S,
        _ sourceKeyPath: KeyPath<S, P>
    ) -> Self where P.Output == T, P.Failure == Never {
        subscribeToViewIsAvailable(withHandlerIdentifier: identifier, from: provider) { view, source in
            let publisher = source[keyPath: sourceKeyPath]
            return view.subscribe(destinationKeyPath, to: publisher)
        }
    }

    func assign<U, P: Publisher, T: ViewIsAvailableProvider>(
        withHandlerIdentifier identifier: AnyHashable = UUID(),
        to destinationKeyPath: ReferenceWritableKeyPath<Self, U>,
        from provider: T,
        _ publisherBuilder: @escaping (Self, T) -> P
    ) -> Self where P.Output == U, P.Failure == Never {
        subscribeToViewIsAvailable(withHandlerIdentifier: identifier, from: provider) { view, source in
            let publisher = publisherBuilder(view, source)
            return view.subscribe(destinationKeyPath, to: publisher)
        }
    }
}
