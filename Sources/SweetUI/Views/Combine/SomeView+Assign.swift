import Combine
import UIKit


public extension SomeView {

    func assign<C: CancellablesStorageProvider, P: Publisher>(to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output>, from subscriberFactory: SubscriberFactory<C, P>) -> Self where P.Failure == Never {
        subscriberFactory.makeSubscriber(with: self) { view, _, value in
            view[keyPath: destinationKeyPath] = value
        }
        return self
    }


    // MARK: Promote non-optional publisher to optional
    
    func assign<C: CancellablesStorageProvider, P: Publisher>(to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output?>, from subscriberFactory: SubscriberFactory<C, P>) -> Self where P.Failure == Never {
        subscriberFactory.makeSubscriber(with: self) { view, _, value in
            view[keyPath: destinationKeyPath] = value            
        }
        return self
    }
}
