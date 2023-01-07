import Foundation
import Combine


public protocol PublisherRespondable: AnyObject {

}


// MARK: - Default conformance

extension NSObject: PublisherRespondable { }


// MARK: - Subscribing

public extension PublisherRespondable {

    func subscribe<V, P: Publisher>(_ keyPath: ReferenceWritableKeyPath<Self, V>, to publisher: P) -> AnyCancellable where P.Output == V, P.Failure == Never {
        publisher.sink { [weak self] value in
            self?[keyPath: keyPath] = value
        }
    }

    func subscribe<V, P: Publisher>(_ keyPath: ReferenceWritableKeyPath<Self, V>, to publisherBuilder: () -> P) -> AnyCancellable where P.Output == V, P.Failure == Never {
        let publisher = publisherBuilder()
        return publisher.sink { [weak self] value in
            self?[keyPath: keyPath] = value
        }
    }
}


// MARK: - Change handling

public extension PublisherRespondable {

    func onChange<V, P: Publisher>(of publisher: P, perform action: @escaping (Self, V) -> Void) -> AnyCancellable where P.Output == V, P.Failure == Never {
        publisher.sink { [weak self] value in
            guard let self = self else {
                return
            }
            action(self, value)
        }
    }
}
