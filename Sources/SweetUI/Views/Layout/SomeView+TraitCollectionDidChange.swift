import UIKit


public extension SomeView {

    func onTraitCollectionChange<T: TraitCollectionDidChangeProvider>(of provider: T, _ handler: @escaping (Self, UITraitCollection?, UITraitCollection) -> Void) -> Self {
        provider.addTraitCollectionDidChangeHandler { [weak self] previous, current in
            guard let self = self else {
                return false
            }
            handler(self, previous, current)
            return true
        }
        return self
    }
}
