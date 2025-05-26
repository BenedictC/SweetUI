import Combine


// MARK: - _MutableBinding

public class _MutableBinding<Output>: OneWayBinding<Output> {

    // MARK: Properties

    // Value

    public override var value: Output {
        get { getter() }
        set { receiveValue(newValue) }
    }

    internal let subject: AnySubject<Output, Never>
    private let externalStorageToken: AnyHashable?


    // MARK: Instance life cycle

    public init(
        wrappedValue: Output,
        willSet: @escaping (_ currentValue: Output, _ proposedValue: Output) -> Output = { $1 },
        didSet: @escaping (_ oldValue: Output, _ newValue: Output) -> Void = { _, _ in },
        options: BindingOptions = .default
    ) {
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
        self.externalStorageToken = nil
        let getter = { subject.value }
        super.init(publisher: subject, get: getter, options: options)
    }

    public init(options: BindingOptions = .default) where Output: _Optionalable {
        let currentValueSubject = CurrentValueSubject<Output.Wrapped?, Never>(nil) as! CurrentValueSubject<Output, Never>
        self.subject = currentValueSubject.eraseToAnySubject()
        self.externalStorageToken = nil
        super.init(currentValueSubject: currentValueSubject, options: options)
    }

    public init(options: BindingOptions = .default) {
        let passthroughSubject = PassthroughSubject<Output, Never>()
        self.subject = passthroughSubject.eraseToAnySubject()

        let externalStorageToken = UniqueIdentifier("_MutableBinding")
        self.externalStorageToken = externalStorageToken
        super.init(
            publisher: passthroughSubject,
            get: {
                let anyValue = deferredStorage[externalStorageToken]
                guard let anyValue else {
                    fatalError("Attempted to access value before it has been initialized")
                }
                guard let value = anyValue as? Output else {
                    fatalError()
                }
                return value
            },
            options: options
        )
    }

    public override init(wrappedValue: Output, options: BindingOptions = .default) {
        let currentValueSubject = CurrentValueSubject<Output, Never>(wrappedValue)
        self.subject = currentValueSubject.eraseToAnySubject()
        self.externalStorageToken = nil
        super.init(currentValueSubject: currentValueSubject, options: options)
    }

    public override init(currentValueSubject: CurrentValueSubject<Output, Never>, options: BindingOptions = .default) {
        self.subject = currentValueSubject.eraseToAnySubject()
        self.externalStorageToken = nil
        super.init(currentValueSubject: currentValueSubject, options: options)
    }

    internal init(subject: AnySubject<Output, Never>, cancellable: AnyCancellable?, getter: @escaping () -> Output, options: BindingOptions = .default) {
        self.subject = subject
        self.externalStorageToken = nil
        super.init(publisher: subject, get: getter, options: options)
    }


    // MARK: - Accessors

    func receiveValue(_ fresh: Output) { 
        if let externalStorageToken {
            deferredStorage[externalStorageToken] = fresh
        }
        subject.send(fresh)
    }


    private static func makeCurrentValueSubject() -> CurrentValueSubject<Output, Never>? where Output: _Optionalable {
        (CurrentValueSubject<Output.Wrapped?, Never>(nil) as! CurrentValueSubject<Output, Never>)
    }


    private static func makeCurrentValueSubject() -> CurrentValueSubject<Output, Never>? {
        nil
    }
}


// MARK: - Deferred Initialization


private var deferredStorage = [AnyHashable: Any]()


// MARK: - Additional initializers

public extension _MutableBinding {

    /// Allows a Binding to be created from a  @Published property
    convenience init<Root: AnyObject>(
        forPropertyOf object: Root,
        at publisherKeyPath: KeyPath<Root, some Publisher<Output, Never>>,
        _ accessorKeyPath: ReferenceWritableKeyPath<Root, Output>
    ) {
        let subject = AnySubject<Output, Never>(publishedBy: object, get: publisherKeyPath, set: accessorKeyPath)
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


