import UIKit


public extension SomeView {

    func onTraitCollectionChange<T: TraitCollectionPublisherProvider>(
        of provider: T,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store,
        _ handler: @escaping (Self, T, PublishedTraitCollection) -> Void)
    -> Self {
        let view = self

        let cancellable = provider.traitCollectionPublisher.sink { [weak view, weak provider] publishedTraitCollection in
            guard let view, let provider else { return }
            handler(view, provider, publishedTraitCollection)
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
