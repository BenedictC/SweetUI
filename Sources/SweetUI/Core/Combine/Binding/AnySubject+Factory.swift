import Combine


// MARK: - @Published

/// Transforms a @Published property into a Subject
public extension AnySubject {

    convenience init<T: AnyObject>(publishedBy object: T, get getPublisher: KeyPath<T, Published<Output>.Publisher>, set setValue: ReferenceWritableKeyPath<T, Output>) where Failure == Never {
        let publisher = object[keyPath: getPublisher]
        self.init(
            receiveHandler: { publisher.receive(subscriber: $0) },
            sendValueHandler: { [weak object] in object?[keyPath: setValue] = $0 },
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
