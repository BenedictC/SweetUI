import Foundation
import Combine


// MARK: - ViewIsAvailableProvider continuous

public extension SomeView {

    func subscribeToViewIsAvailable<T: ViewIsAvailableProvider>(
        withHandlerIdentifier identifier: AnyHashable = UUID(),
        from provider: T,
        @CancellablesBuilder handler: @escaping (Self, T) -> AnyCancellable
    ) -> Self {
        provider.addViewIsAvailableHandler(withIdentifier: identifier) { [weak self, weak provider] in
            guard let self = self,
                  let provider = provider
            else {
                // if self is gone then the handler is no longer useful so remove it
                provider?.removeViewIsAvailableHandler(forIdentifier: identifier)
                return ()
            }
            return handler(self, provider)
        }
        return self
    }
}
