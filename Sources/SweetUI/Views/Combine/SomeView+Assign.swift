import Combine
import UIKit


public extension SomeView {

    func assign<A: ViewAvailabilityProvider, P: Publisher>(to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output>, from publisherParameter: ValueParameter<A, Self, P>) -> Self where P.Failure == Never {
        publisherParameter.context = self
        publisherParameter.invalidationHandler = { [weak publisherParameter] in
            guard let root = publisherParameter?.root else { return }
            guard let identifier = publisherParameter?.identifier else { return }
            root.unregisterViewAvailability(forIdentifier: identifier)
        }
        publisherParameter.root?.registerForViewAvailability(withIdentifier: publisherParameter.identifier) {
            guard let publisher = publisherParameter.makeValue() else { return nil }
            return publisherParameter.context?.subscribe(destinationKeyPath, to: publisher)
        }
        return self
    }
    

    // MARK: Promote non-optional publisher to optional

    func assign<A: ViewAvailabilityProvider, P: Publisher>(to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output?>, from publisherParameter: ValueParameter<A, Self, P>) -> Self where P.Failure == Never {
        publisherParameter.context = self
        publisherParameter.invalidationHandler = { [weak publisherParameter] in
            guard let root = publisherParameter?.root else { return }
            guard let identifier = publisherParameter?.identifier else { return }
            root.unregisterViewAvailability(forIdentifier: identifier)
        }
        publisherParameter.root?.registerForViewAvailability(withIdentifier: publisherParameter.identifier) {
            guard let publisher = publisherParameter.makeValue() else { return nil }
            return publisherParameter.context?.subscribe(destinationKeyPath, to: publisher.map(Optional.some))
        }
        return self
    }
}
