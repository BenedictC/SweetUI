import Combine


// MARK: - Convenience 

public extension AnySubject {

    convenience init<T: AnyObject, P: Publisher>(for object: T, _ keyPath: ReferenceWritableKeyPath<T, Output>, publisher: P) where P.Output == Output, P.Failure == Never, Failure == Never {
        self.init(
            receiveHandler: { publisher.receive(subscriber: $0) },
            sendValueHandler: { [weak object] in object?[keyPath: keyPath] = $0 },
            sendCompletionHandler: { _ in /* Published can't complete */ },
            sendSubscriptionHandler: { _ in /* ??? */ }
        )
    }
}


// MARK: - Public Initializers

public extension AnySubject {

    convenience init<T: Subject>(_ wrapped: T) where T.Output == Output, T.Failure == Failure {
        self.init(
            receiveHandler: { wrapped.receive(subscriber: $0) },
            sendValueHandler: { wrapped.send($0) },
            sendCompletionHandler: { wrapped.send(completion: $0) },
            sendSubscriptionHandler: { wrapped.send(subscription: $0) }
        )
    }
}


// MARK: - Type erasure factory

public extension Subject {

    func eraseToAnySubject() -> AnySubject<Output, Failure> {
        if let existing = self as? AnySubject<Output, Failure> {
            return existing
        }
        return AnySubject(self)
    }
}
