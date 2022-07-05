import UIKit


public extension SomeView {

    func onTraitCollectionChange<T: TraitCollectionDidChangeProvider>(handlerIdentifier: AnyHashable = UUID(), of provider: T, _ handler: @escaping (Self, UITraitCollection?, UITraitCollection) -> Void) -> Self {
        provider.addTraitCollectionDidChangeHandler(withIdentifier: handlerIdentifier) { [weak self] previous, current in
            guard let self = self else {
                return
            }
            handler(self, previous, current)
        }
        return self
    }
}
