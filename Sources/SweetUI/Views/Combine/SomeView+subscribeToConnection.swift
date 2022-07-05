import Foundation
import Combine


// MARK: - ViewIsAvailableProvider continuous

public extension SomeView {

    func subscribeToViewIsAvailable<T: ViewIsAvailableProvider>(of provider: T, handlerIdentifier: AnyHashable = UUID(), @CancellablesBuilder handler: @escaping (Self, T) -> AnyCancellable) -> Self {
        provider.addViewIsAvailableHandler(withIdentifier: handlerIdentifier) { [weak self, weak provider] in
            guard let self = self,
                  let provider = provider
            else {
                // if self is gone then the handler is no longer useful so remove it
                provider?.removeViewIsAvailableHandler(forIdentifier: handlerIdentifier)
                return ()
            }
            return handler(self, provider)
        }
        return self
    }
}
