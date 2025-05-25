import Combine

public typealias BindingOneWay<T> = Binding<T>.OneWay


@propertyWrapper
public final class Binding<Output>: _MutableBinding<Output>, Subject {
    
    // MARK: Properties

    // ProjectedValue

    public var projectedValue: Binding<Output> { self }


    // WrappedValue

    @available(*, unavailable, message: "@Binding is only available on properties of classes")
    public var wrappedValue: Output {
        get { getter() }
        set { receiveValue(newValue) }
    }

    // Subscript to allow classes to access the wrappedValue
    public static subscript<EnclosingObject: AnyObject>(
        _enclosingInstance object: EnclosingObject,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingObject, Output>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingObject, Binding<Output>>
    ) -> Output {
        get {
            let binding = object[keyPath: storageKeyPath]
            return binding.getter()
        }
        set {
            let binding = object[keyPath: storageKeyPath]
            binding.receiveValue(newValue)
        }
    }


    // MARK: Instance life cycle

    // Init is handled by _MutableBinding


    // MARK: Subject
    
    public func send(_ value: Output) {
        receiveValue(value)
    }
    
    public func send(completion: Subscribers.Completion<Never>) {
        subject.send(completion: completion)
    }
    
    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }
}


// MARK: - Avoid collision with another framework

public typealias UIBinding = Binding



// MARK: - Subscripts

public extension Binding {

    subscript<T>(_ keyPath: WritableKeyPath<Output, T>) -> Binding<T> {
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
        fatalError()
        """
        let binding = Binding<T>(
            subject: subject,
            getter: {
                let root = rootGetter()
                return root[keyPath: keyPath]
            }
        )
        return binding
        """
    }

    subscript<T>(_ keyPath: WritableKeyPath<Output, Optional<T>>, default defaultValue: T) -> Binding<T> {
        if keyPath == \.self, let existing = self as? Binding<T> { return existing }

        let rootSubject = subject
        let rootGetter = getter
        let setter = { (newValue: T) in
            var rootValue = rootGetter()
            rootValue[keyPath: keyPath] = newValue
            rootSubject.send(rootValue)
        }
        let subject = AnySubject(
            get: publisher.map { $0[keyPath: keyPath] ?? defaultValue },
            set: setter
        )
        fatalError()
        """
        let binding = Binding<T>(
            subject: subject,
            getter: {
                let root = rootGetter()
                return root[keyPath: keyPath] ?? defaultValue
            }
        )
        return binding
        """
    }
}


func todo() {
    """
    # Writing
    - When there's an optional in a chain then the setter will fail any of the internal nodes are nil
        - what would returning a default value mean in this situation?
    
    # Reading
    - A default value is only for the final value
    - Flattening would mean that the publisher omits sending values when the value is nil. This means the receiver may have an out of date value
    - Would flatten make more sense? 
    """
}
