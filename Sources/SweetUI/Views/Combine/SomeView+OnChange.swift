import Foundation
import Combine


public extension SomeView {

    func onChange<C: CancellablesStorageProvider, V, P: Publisher>(of factory: SubscriberFactory<C, P>, perform action: StoredAction<C, Self>) -> Self where P.Output == V, P.Failure == Never {
        // We don't need to store action because it's captured in a block is stored
        let handler = action.handler
        factory.makeSubscriber(with: self) { view, root, _ in
            handler(root, view)
        }
        return self
    }
}
