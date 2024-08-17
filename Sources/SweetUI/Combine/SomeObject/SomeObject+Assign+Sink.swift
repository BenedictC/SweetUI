import Foundation
import Combine


// MARK: - Assign

/// Take a keyPath and return a AnyCancellable
public extension SomeObject {

    func assign<V, P: Publisher>(to keyPath: ReferenceWritableKeyPath<Self, V>, from publisher: P) -> AnyCancellable where P.Output == V, P.Failure == Never {
        publisher.sink { [weak self] value in
            self?[keyPath: keyPath] = value
        }
    }

    func assign<V, P: Publisher>(to keyPath: ReferenceWritableKeyPath<Self, V>, from publisherBuilder: () -> P) -> AnyCancellable where P.Output == V, P.Failure == Never {
        let publisher = publisherBuilder()
        return publisher.sink { [weak self] value in
            self?[keyPath: keyPath] = value
        }
    }


    // MARK: Optional variants

    func assign<V, P: Publisher>(to keyPath: ReferenceWritableKeyPath<Self, V?>, from publisher: P) -> AnyCancellable where P.Output == V, P.Failure == Never {
        publisher.sink { [weak self] value in
            self?[keyPath: keyPath] = value
        }
    }

    func assign<V, P: Publisher>(to keyPath: ReferenceWritableKeyPath<Self, V?>, from publisherBuilder: () -> P) -> AnyCancellable where P.Output == V, P.Failure == Never {
        let publisher = publisherBuilder()
        return publisher.sink { [weak self] value in
            self?[keyPath: keyPath] = value
        }
    }
}


// MARK: - Sink

/// Take a closure and return a AnyCancellable
public extension SomeObject {

    func sink<V, P: Publisher>(receiveValue publisher: P, perform action: @escaping (Self, V) -> Void) -> AnyCancellable where P.Output == V, P.Failure == Never {
        publisher.sink { [weak self] value in
            guard let self = self else {
                return
            }
            action(self, value)
        }
    }
}
