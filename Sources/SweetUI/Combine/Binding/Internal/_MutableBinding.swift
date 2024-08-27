import Combine


// MARK: - _MutableBinding

public class _MutableBinding<Output>: OneWayBinding<Output> {

    // MARK: Properties

    internal let subject: AnySubject<Output, Never>


    // MARK: Instance life cycle

    internal init(subject: AnySubject<Output, Never>, cancellable: AnyCancellable?, getter: @escaping () -> Output, options: Options = .default) {
        self.subject = subject
        super.init(publisher: subject, cancellable: nil, get: getter, options: options)
    }

    public init(
        wrappedValue: Output,
        willSet: @escaping (_ currentValue: Output, _ proposedValue: Output) -> Output = { $1 },
        didSet: @escaping (_ oldValue: Output, _ newValue: Output) -> Void = { _, _ in },
        options: Options = .default) {
        let subject = CurrentValueSubject<Output, Never>(wrappedValue)
        self.subject = AnySubject(
            receiveHandler: { subject.receive(subscriber: $0) },
            sendValueHandler: { proposed in
                let current = subject.value
                let accepted = willSet(current, proposed)
                subject.send(accepted)
                didSet(current, accepted)
            },
            sendCompletionHandler: { _ in /* Bindings can't complete */ },
            sendSubscriptionHandler: { _ in /* ??? */ }
        )
        let getter = { subject.value }
        super.init(publisher: subject, cancellable: nil, get: getter, options: options)
    }

    public override init(currentValueSubject: CurrentValueSubject<Output, Never>, options: Options = .default) {
        self.subject = currentValueSubject.eraseToAnySubject()
        super.init(currentValueSubject: currentValueSubject, options: options)
    }
}


// MARK: - Additional initializers

public extension _MutableBinding {

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

public extension _MutableBinding {

    func asOneWayBinding() -> OneWayBinding<Output> {
        self
    }
}


