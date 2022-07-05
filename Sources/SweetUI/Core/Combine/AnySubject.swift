import Combine


public final class AnySubject<Output, Failure: Error>: Subject {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Failure


    // MARK: Instance life cycle

    init(
        receiveHandler: @escaping (AnySubscriber<Output, Failure>) -> Void,
        sendValueHandler: @escaping (Output) -> Void,
        sendCompletionHandler: @escaping (Subscribers.Completion<Failure>) -> Void,
        sendSubscriptionHandler: @escaping (Subscription) -> Void)
    {
        self.receiveHandler = receiveHandler
        self.sendValueHandler = sendValueHandler
        self.sendCompletionHandler = sendCompletionHandler
        self.sendSubscriptionHandler = sendSubscriptionHandler
    }


    // MARK: Properties

    let receiveHandler: (AnySubscriber<Output, Failure>) -> Void
    let sendValueHandler: (Output) -> Void
    let sendCompletionHandler: (Subscribers.Completion<Failure>) -> Void
    let sendSubscriptionHandler: (Subscription) -> Void


    // MARK: Subject

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let anySubscriber = AnySubscriber(subscriber)
        receiveHandler(anySubscriber)
    }

    public func send(_ value: Output) {
        sendValueHandler(value)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        sendCompletionHandler(completion)
    }

    public func send(subscription: Subscription) {
        sendSubscriptionHandler(subscription)
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
