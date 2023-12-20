import Combine


// MARK: - Binding

@propertyWrapper
public final class Binding<Output>: OneWayBinding<Output>, Subject {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never


    // MARK: Properties

    override public var value: Output {
        get { wrappedValue }
        set { wrappedValue = newValue }
    }

    public var projectedValue: Binding<Output> { self }
    override public var wrappedValue: Output {
        get { getter() }
        set { setter(newValue) }
    }

    private let subject: AnySubject<Output, Never>
    // private let getter: () -> Output
    private let setter: (Output) -> Void


    // MARK: Instance life cycle

    public override init(wrappedValue: Output) {
        let subject = CurrentValueSubject<Output, Never>(wrappedValue)
        self.subject = subject.eraseToAnySubject()
        self.setter = { subject.send($0) }
        let getter = { subject.value }
        super.init(publisher: subject, get: getter)
    }

    internal init(subject: AnySubject<Output, Never>, getter: @escaping () -> Output, setter: @escaping (Output) -> Void) {
        self.subject = subject
        self.setter = setter
        super.init(publisher: subject, get: getter)
    }


    // MARK: Publisher

    override public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }


    // MARK: Subject

    public func send(_ value: Output) {
        setter(value)
    }

    public func send(completion: Subscribers.Completion<Never>) {
        subject.send(completion: completion)
    }

    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }
}


// MARK: - Init from publishers

public extension Binding {

    convenience init(currentValueSubject: CurrentValueSubject<Output, Never>) {
        self.init(
            subject: currentValueSubject.eraseToAnySubject(),
            getter: { currentValueSubject.value },
            setter: { currentValueSubject.send($0) }
        )
    }

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
}


// MARK: - Init from value

public extension Binding {

    convenience init(initialValue: Output, set setter: @escaping (_ current: Output, _ proposed: Output) -> Output = { $1 }) {
        let subject = CurrentValueSubject<Output, Never>(initialValue)
        self.init(
            subject: subject.eraseToAnySubject(),
            getter: { subject.value },
            setter: { proposed in
                let current = subject.value
                let fresh = setter(current, proposed)
                subject.send(fresh)
            }
        )
    }
}


// MARK: - Overly descriptive typealias

public typealias TwoWayBinding = Binding
