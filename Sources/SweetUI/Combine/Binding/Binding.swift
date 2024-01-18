import Combine


// MARK: - Binding

@propertyWrapper
@dynamicMemberLookup
public final class Binding<Output>: OneWayBinding<Output>, Subject {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never


    // MARK: Properties

    public var projectedValue: Binding<Output> { self }
    override public var wrappedValue: Output {
        get { getter() }
        set { subject.send(newValue) }
    }

    private let subject: AnySubject<Output, Never>


    // MARK: Instance life cycle

    internal init(subject: AnySubject<Output, Never>, cancellable: AnyCancellable?, getter: @escaping () -> Output) {
        self.subject = subject
        super.init(publisher: subject, cancellable: nil, get: getter)
    }

    public override init(wrappedValue: Output) {
        let subject = CurrentValueSubject<Output, Never>(wrappedValue)
        self.subject = subject.eraseToAnySubject()
        let getter = { subject.value }
        super.init(publisher: subject, cancellable: nil, get: getter)
    }

    public override init(currentValueSubject: CurrentValueSubject<Output, Never>) {
        self.subject = currentValueSubject.eraseToAnySubject()
        super.init(currentValueSubject: currentValueSubject)
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
    

    // MARK: Publisher

    override public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
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


// MARK: - Additional initializers

public extension Binding {

    /// Allows a Binding to be created from a  @Published property
    convenience init<Root: AnyObject, P: Publisher>(
        for keyPaths: (publisher: KeyPath<Root, P>, accessor: ReferenceWritableKeyPath<Root, Output>), 
        of object: Root
    ) where P.Output == Output, P.Failure == Never {
        let subject = AnySubject(publishedBy: object, get: keyPaths.publisher, set: keyPaths.accessor)
        self.init(
            subject: subject,
            cancellable: nil,
            getter: { object[keyPath: keyPaths.accessor] }
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
