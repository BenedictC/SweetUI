import UIKit


public extension SomeView {

    func onTraitCollectionChange<T: TraitCollectionPublisherProvider & CancellablesStorageProvider>(handlerIdentifier: AnyHashable = UUID(), of provider: T, _ handler: @escaping (Self, T, PublishedTraitCollection) -> Void) -> Self {
        provider.collectCancellables(for: handlerIdentifier) {
            provider.traitCollectionPublisher.sink { [weak self, weak provider] publishedTraitCollection in
                guard
                    let self = self,
                    let provider = provider
                else {
                    return
                }
                handler(self, provider, publishedTraitCollection)
            }
        }
        return self
    }
}
