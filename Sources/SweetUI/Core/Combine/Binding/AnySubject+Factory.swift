import Combine


// MARK: - @Published

/// Transforms a @Published property into a Subject
public extension AnySubject {

    convenience init<T: AnyObject, P: Publisher>(publishedBy object: T, get getPublisher: KeyPath<T, P>, set setKeyPath: ReferenceWritableKeyPath<T, Output>) where Failure == Never, P.Output == Output, P.Failure == Never {
        let publisher = object[keyPath: getPublisher]
        self.init(
            receiveHandler: { publisher.receive(subscriber: $0) },
            sendValueHandler: { [weak object] in object?[keyPath: setKeyPath] = $0 },
            sendCompletionHandler: { _ in /* Published can't complete */ },
            sendSubscriptionHandler: { _ in /* ??? */ }
        )
    }    
}


// MARK: - Public Initializers

public extension AnySubject {

    convenience init<P: Publisher>(get publisher: P, set setHandler: @escaping (Output) -> Void) where P.Output == Output, P.Failure == Failure {
        // TODO: How do we cancel the set handler? Do we need to?
        self.init(
            receiveHandler: { publisher.receive(subscriber: $0) },
            sendValueHandler: setHandler,
            sendCompletionHandler: { _ in /* Published can't complete */ },
            sendSubscriptionHandler: { _ in /* ??? */ }
        )
    }

    convenience init<T: Subject>(_ wrapped: T) where T.Output == Output, T.Failure == Failure {
        self.init(
            receiveHandler: { wrapped.receive(subscriber: $0) },
            sendValueHandler: { wrapped.send($0) },
            sendCompletionHandler: { wrapped.send(completion: $0) },
            sendSubscriptionHandler: { wrapped.send(subscription: $0) }
        )
    }
}


// MARK: - Type erasure

public extension Subject {

    func eraseToAnySubject() -> AnySubject<Output, Failure> {
        if let existing = self as? AnySubject<Output, Failure> {
            return existing
        }
        return AnySubject(self)
    }
}
