import Combine


internal final class AnySubject<Output, Failure: Error>: Subject {

    // MARK: Types

    typealias Output = Output
    typealias Failure = Failure


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

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let anySubscriber = AnySubscriber(subscriber)
        receiveHandler(anySubscriber)
    }

    func send(_ value: Output) {
        sendValueHandler(value)
    }

    func send(completion: Subscribers.Completion<Failure>) {
        sendCompletionHandler(completion)
    }

    func send(subscription: Subscription) {
        sendSubscriptionHandler(subscription)
    }
}
