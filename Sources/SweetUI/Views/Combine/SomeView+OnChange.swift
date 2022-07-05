import Foundation
import Combine


// MARK: - ViewIsAvailableProvider continuous

public extension SomeView {

    func onChange<V, S: Publisher, P: ViewIsAvailableProvider>(of provider: P, _ keyPath: KeyPath<P, S>, handlerIdentifier: AnyHashable = UUID(), perform action: @escaping (Self, P, V) -> Void) -> Self where S.Output == V, S.Failure == Never {
        subscribeToViewIsAvailable(of: provider, handlerIdentifier: handlerIdentifier) { view, provider in
            let publisher = provider[keyPath: keyPath]
            return publisher.sink { action(view, provider, $0) }
        }
    }
}
