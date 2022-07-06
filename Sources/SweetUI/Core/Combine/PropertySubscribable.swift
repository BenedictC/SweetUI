import Foundation
import Combine


public protocol PropertySubscribable: AnyObject {

}

public extension PropertySubscribable {

    func subscribe<V, P: Publisher>(_ keyPath: ReferenceWritableKeyPath<Self, V>, to publisher: P) -> AnyCancellable where P.Output == V, P.Failure == Never {
        publisher.sink { [weak self] value in
            self?[keyPath: keyPath] = value
        }
    }
}


// MARK: -

extension NSObject: PropertySubscribable { }

