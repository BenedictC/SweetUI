import UIKit


public extension SomeView {

    func onTraitCollectionChange<T: TraitCollectionDidChangeProvider>(handlerIdentifier: AnyHashable = UUID(), of provider: T, _ handler: @escaping (Self, T, UITraitCollection?, UITraitCollection) -> Void) -> Self {
        provider.addTraitCollectionDidChangeHandler(withIdentifier: handlerIdentifier) { [weak self, weak provider] previous, current in
            guard
                let self = self,
                let provider = provider
            else {
                return
            }
            handler(self, provider, previous, current)
        }
        return self
    }
}
