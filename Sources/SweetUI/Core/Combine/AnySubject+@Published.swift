import Combine


// MARK: - @Published wrapper

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
