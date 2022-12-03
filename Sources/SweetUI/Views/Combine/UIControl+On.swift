import Combine
import UIKit


//  MARK: - On Event

public extension SomeView where Self: UIControl {

    func on<C: CancellablesStorageProvider>(_ event: UIControl.Event, perform action: StoredAction<C, Self>) -> Self {
        let handler = action.handler
        let cancellablesStorageProvider = action.cancellablesStorageProvider
        let cancellable = self.addAction(for: event) { [weak self, weak cancellablesStorageProvider] _, _ in
            guard let cancellablesStorageProvider,
                  let self else { return }
            handler(cancellablesStorageProvider, self)
        }
        let id = action.cancellableIdentifier
        cancellablesStorageProvider.storeCancellable(cancellable, for: id)
        return self
    }
}
