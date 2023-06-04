import Combine


// Transforms a @Published property into a Subject
public final class PublishedSubject<V>: Subject {

    public typealias Output = V
    public typealias Failure = Never


    private let setter: (V) -> Void
    private let publisher: Published<V>.Publisher


    public init<Root>(_ object: Root, read: KeyPath<Root, Published<V>.Publisher>, write: ReferenceWritableKeyPath<Root, V>) {
        let publisher = object[keyPath: read]
        self.publisher = publisher
        self.setter = { object[keyPath: write] = $0 }
    }


    public func send(_ value: V) {
        setter(value)
    }

    public func send(completion: Subscribers.Completion<Never>) {
        // A published property doesn't complete because the owning object is retained by this subject.
    }

    public func send(subscription: Subscription) {
        // TODO: What do we do here?
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, V == S.Input {
        // Should this subscribe to the publisher?
        publisher.receive(subscriber: subscriber)
    }
}

