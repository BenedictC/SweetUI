import Combine


// MARK: - Binding

@propertyWrapper
public final class Binding<Output>: Subject {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never


    // MARK: Properties

    public var value: Output {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }

    public var projectedValue: Binding<Output> { self }
    public var wrappedValue: Output {
        get { getter() }
        set { setter(newValue) }
    }

    private let subject: AnySubject<Output, Never>
    private let getter: () -> Output
    private let setter: (Output) -> Void


    // MARK: Instance life cycle

    public init(wrappedValue: Output) {
        let subject = CurrentValueSubject<Output, Never>(wrappedValue)
        self.subject = subject.eraseToAnySubject()
        self.getter = { subject.value }
        self.setter = { subject.send($0) }
    }

    internal init(subject: AnySubject<Output, Never>, getter: @escaping () -> Output, setter: @escaping (Output) -> Void) {
        self.subject = subject
        self.getter = getter
        self.setter = setter
    }


    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }


    // MARK: Subject

    public func send(_ value: Output) {
        subject.send(value)
    }

    public func send(completion: Subscribers.Completion<Never>) {
        subject.send(completion: completion)
    }

    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }
}


// MARK: - Init

public extension Binding {

    convenience init<P: Publisher>(publisher: P, get getter: @escaping () -> Output, set setter: @escaping (Output) -> Void) where P.Output == Output, P.Failure == Never  {
        let subject = AnySubject(get: publisher, set: setter)
        self.init(
            subject: subject,
            getter: getter,
            setter: setter
        )
    }

    convenience init<T: AnyObject, P: Publisher>(publishedBy object: T, get getPublisher: KeyPath<T, P>, set setKeyPath: ReferenceWritableKeyPath<T, Output>)  where P.Output == Output, P.Failure == Never {
        let subject = AnySubject(publishedBy: object, get: getPublisher, set: setKeyPath)
        self.init(
            subject: subject,
            getter: { object[keyPath: setKeyPath] },
            setter: { object[keyPath: setKeyPath] = $0 }
        )
    }

    convenience init(initialValue: Output, set setter: @escaping (Output) -> Output? = { $0 }) {
        let subject = CurrentValueSubject<Output, Never>(initialValue)
        self.init(
            subject: subject.eraseToAnySubject(),
            getter: { subject.value },
            setter: { setter($0).flatMap { subject.send($0) } }
        )
    }
}


// MARK: -

public typealias TwoWayBinding = Binding
