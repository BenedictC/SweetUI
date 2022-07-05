import Combine


// MARK: - @Published wrapper

public extension AnySubject {

    convenience init<T: AnyObject>(property keyPath: ReferenceWritableKeyPath<T, Output>, of object: T, publisher: Published<Output>.Publisher) where Failure == Never {
        self.init(
            receiveHandler: { publisher.receive(subscriber: $0) },
            sendValueHandler: { [weak object] in object?[keyPath: keyPath] = $0 },
            sendCompletionHandler: { _ in /* Published can't complete */ },
            sendSubscriptionHandler: { _ in /* ??? */ }
        )
    }
}
