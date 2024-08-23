import Combine


// MARK: - Binding

@propertyWrapper
@dynamicMemberLookup
public final class Binding<Output>: OneWayBinding<Output>, Subject {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never

    public typealias Options = OneWayBinding<Output>.Options


    // MARK: Properties

    public var projectedValue: Binding<Output> { self }
    override public var wrappedValue: Output {
        get { getter() }
        set { subject.send(newValue) }
    }

    private let subject: AnySubject<Output, Never>


    // MARK: Instance life cycle

    internal init(subject: AnySubject<Output, Never>, cancellable: AnyCancellable?, getter: @escaping () -> Output, options: Options = .default) {
        self.subject = subject
        super.init(publisher: subject, cancellable: nil, get: getter, options: options)
    }

    public  init(
        wrappedValue: Output,
        willSet: @escaping (_ current:  Output, _ proposed: Output) -> Output = { $1 },
        didSet:  @escaping (_ oldValue: Output, _ newValue: Output) -> Void = { _, _ in },
        options: Options = .default) {
        let subject = CurrentValueSubject<Output, Never>(wrappedValue)
        self.subject = AnySubject(
            receiveHandler: { subject.receive(subscriber: $0) },
            sendValueHandler: { proposed in
                let current = subject.value
                let newValue = willSet(current, proposed)
                subject.send(newValue)
                let oldValue = current
                didSet(oldValue, newValue)
            },
            sendCompletionHandler: { _ in /* Published can't complete */ },
            sendSubscriptionHandler: { _ in /* ??? */ }
        )
        let getter = { subject.value }
        super.init(publisher: subject, cancellable: nil, get: getter, options: options)
    }

    public override init(currentValueSubject: CurrentValueSubject<Output, Never>, options: Options = .default) {
        self.subject = currentValueSubject.eraseToAnySubject()
        super.init(currentValueSubject: currentValueSubject, options: options)
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


    // MARK: Subscripts

    public subscript<T>(binding keyPath: WritableKeyPath<Output, T>) -> Binding<T> {
        if keyPath == \.self, let existing = self as? Binding<T> { return existing }

        let rootSubject = subject
        let rootGetter = getter
        let setter = { (newValue: T) in
            var rootValue = rootGetter()
            rootValue[keyPath: keyPath] = newValue
            rootSubject.send(rootValue)
        }
        let subject = AnySubject(
            get: publisher.map { $0[keyPath: keyPath] },
            set: setter
        )
        let binding = Binding<T>(
            subject: subject,
            cancellable: nil,
            getter: {
                let root = rootGetter()
                return root[keyPath: keyPath]
            }
        )
        return binding
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Output, T>) -> Binding<T> {
        return self[binding: keyPath]
    }
}


// MARK: - Additional initializers

public extension Binding {

    /// Allows a Binding to be created from a  @Published property
    convenience init<Root: AnyObject, P: Publisher>(
        forPropertyOf object: Root,
        at publisherKeyPath: KeyPath<Root, P>,
        _ accessorKeyPath: ReferenceWritableKeyPath<Root, Output>
    ) where P.Output == Output, P.Failure == Never {
        let subject = AnySubject(publishedBy: object, get: publisherKeyPath, set: accessorKeyPath)
        self.init(
            subject: subject,
            cancellable: nil,
            getter: { object[keyPath: accessorKeyPath] }
        )
    }

    /// Allows for a Binding to be created from a publisher and an non-published property.
    /// Note that the setter allows for the value to be modified or discarding.
    convenience init<P: Publisher>(
        publisher: P,
        get getter: @escaping () -> Output,
        set setter: @escaping (_ newValue: Output) -> Void
    ) where P.Failure == Never {
        let outputPublisher = publisher.map { _ in getter() }
        let subject = AnySubject(get: outputPublisher, set: setter)
        self.init(subject: subject, cancellable: nil, getter: getter)
    }
}


// MARK: - Upcasting (i.e. remove mutability)

public extension Binding {

    func asOneWayBinding() -> OneWayBinding<Output> {
        self
    }
}


// MARK: - Avoid collision with another framework

public typealias UIBinding = Binding
