import Foundation
import Combine


public extension SomeView {

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
