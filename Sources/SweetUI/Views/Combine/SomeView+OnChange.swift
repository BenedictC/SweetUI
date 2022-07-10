import Foundation
import Combine


public extension SomeView {

    func onChange<V, S: Publisher, P: ViewIsAvailableProvider>(
        withHandlerIdentifier identifier: AnyHashable = UUID(),
        of provider: P,
        _ keyPath: KeyPath<P, S>,
        perform action: @escaping (Self, P, V) -> Void
    ) -> Self where S.Output == V, S.Failure == Never {
        subscribeToViewIsAvailable(withHandlerIdentifier: identifier, from: provider) { view, provider in
            let publisher = provider[keyPath: keyPath]
            return publisher.sink { action(view, provider, $0) }
        }
    }
    
    func onChange<V, S: Publisher, P: ViewIsAvailableProvider>(
        withHandlerIdentifier identifier: AnyHashable = UUID(),
        of provider: P,
        _ publisherBuilder: @escaping (P) -> S,
        perform action: @escaping (Self, P, V) -> Void
    ) -> Self where S.Output == V, S.Failure == Never {
        subscribeToViewIsAvailable(withHandlerIdentifier: identifier, from: provider) { view, provider in
            let publisher = publisherBuilder(provider)
            return publisher.sink { action(view, provider, $0) }
        }
    }
}
