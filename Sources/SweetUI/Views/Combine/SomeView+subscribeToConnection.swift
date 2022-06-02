import Foundation
import Combine


// MARK: - ViewConnectionProvider continuous

public extension SomeView {

    func subscribeToConnection<T: ViewConnectionProvider>(of provider: T, connectionIdentifier: AnyHashable = UUID(), @CancellablesBuilder handler: @escaping (Self, T) -> AnyCancellable) -> Self {
        provider.addConnectionHandler(withIdentifier: connectionIdentifier) { [weak self, weak provider] in
            guard let self = self,
                  let provider = provider
            else {
                // if self is gone then the handler is no longer useful so remove it
                provider?.removeConnectionHandler(forIdentifier: connectionIdentifier)
                return ()
            }
            return handler(self, provider)
        }
        return self
    }
}


// MARK: - ViewModelConnectionProvider continuous

public extension SomeView {

    func subscribeToConnection<T: ViewModelConnectionProvider>(of provider: T, connectionIdentifier: AnyHashable = UUID(), @CancellablesBuilder handler: @escaping (Self, T, T.ViewModel) -> AnyCancellable) -> Self {
        provider.addConnectionHandler(withIdentifier: connectionIdentifier) { [weak self, weak provider] in
            guard let self = self,
                  let provider = provider,
                  let viewModel = provider.viewModel
            else {
                // if self is gone then the handler is no longer useful so remove it
                provider?.removeConnectionHandler(forIdentifier: connectionIdentifier)
                return ()
            }
            return handler(self, provider, viewModel)
        }
        return self
    }
}
