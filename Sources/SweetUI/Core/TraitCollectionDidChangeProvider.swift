import UIKit


public protocol TraitCollectionDidChangeProvider: AnyObject {

    typealias TraitCollectionDidChangeHandler = (_ previous: UITraitCollection?, _ current: UITraitCollection) -> Void

    func addTraitCollectionDidChangeHandler(withIdentifier identifier: AnyHashable, _ handler: @escaping TraitCollectionDidChangeHandler)
    func removeTraitCollectionDidChangeHandler(forIdentifier identifier: AnyHashable)
}


protocol _TraitCollectionDidChangeProviderImplementation: TraitCollectionDidChangeProvider {

    var traitCollectionDidChangeProviderStorage: TraitCollectionDidChangeProviderStorage { get }
}


final class TraitCollectionDidChangeProviderStorage {
    var handlers = [AnyHashable: TraitCollectionDidChangeProvider.TraitCollectionDidChangeHandler]()
}


extension _TraitCollectionDidChangeProviderImplementation {

    public func addTraitCollectionDidChangeHandler(withIdentifier identifier: AnyHashable = UUID(), _ handler: @escaping TraitCollectionDidChangeHandler) {
        traitCollectionDidChangeProviderStorage.handlers[identifier] = handler
    }

    public func removeTraitCollectionDidChangeHandler(forIdentifier identifier: AnyHashable) {
        traitCollectionDidChangeProviderStorage.handlers.removeValue(forKey: identifier)
    }

    func invokeTraitCollectionDidChangeHandlers(previous: UITraitCollection?, current: UITraitCollection) {
        let handlers = traitCollectionDidChangeProviderStorage.handlers
        handlers.values.forEach { $0(previous, current) }
    }
}
