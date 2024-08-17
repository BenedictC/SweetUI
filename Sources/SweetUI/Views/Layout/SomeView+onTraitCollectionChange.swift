import UIKit
import Combine


public extension SomeView {

    func onTraitCollectionChange<T: TraitCollectionChangesProvider>(
        of provider: T,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared,
        _ handler: @escaping (Self, T, TraitCollectionChanges) -> Void)
    -> Self {
        let view = self

        let cancellable = provider.traitCollectionChanges.sink { [weak view, weak provider] publishedTraitCollection in
            guard let view, let provider else { return }
            handler(view, provider, publishedTraitCollection)
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}
