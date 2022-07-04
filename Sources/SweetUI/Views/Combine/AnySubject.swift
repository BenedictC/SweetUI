//
//  AnySubject.swift
//  ChordBook
//
//  Created by Benedict Cohen on 03/07/2022.
//

import Foundation
import Combine


public extension Subject {

    func eraseToAnySubject() -> AnySubject<Output, Failure> {
        if let existing = self as? AnySubject<Output, Failure> {
            return existing
        }
        return AnySubject(wrapped: self)
    }
}


// MARK: -

public final class AnySubject<Output, Failure: Error>: Subject {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Failure


    // MARK: Instance life cycle

    init(
        receiveHandler: @escaping (AnySubscriber<Output, Failure>) -> Void,
        sendValueHandler: @escaping (Output) -> Void,
        sendCompletionHandler: @escaping (Subscribers.Completion<Failure>) -> Void,
        sendSubscriptionHandler: @escaping (Subscription) -> Void) {
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


// MARK: - Initializers

public extension AnySubject {

    convenience init<T: Subject>(wrapped: T) where T.Output == Output, T.Failure == Failure {
        self.init(
            receiveHandler: { wrapped.receive(subscriber: $0) },
            sendValueHandler: { wrapped.send($0) },
            sendCompletionHandler: { wrapped.send(completion: $0) },
            sendSubscriptionHandler: { wrapped.send(subscription: $0) }
        )
    }

    convenience init<T: AnyObject>(root: T, valueKeyPath: ReferenceWritableKeyPath<T, Output>, publisher: Published<Output>.Publisher) where Failure == Never {
        self.init(
            receiveHandler: { publisher.receive(subscriber: $0) },
            sendValueHandler: { [weak root] in root?[keyPath: valueKeyPath] = $0 },
            sendCompletionHandler: { _ in /* Published can't complete */ },
            sendSubscriptionHandler: { _ in /* ??? */ }
        )
    }
}
