import Combine

public typealias BindingOneWay<T> = Binding<T>.OneWay


@propertyWrapper
@dynamicMemberLookup
public final class Binding<Output>: _MutableBinding<Output>, Subject {
    
    // MARK: Properties
    
    public var projectedValue: Binding<Output> { self }
    
    override public var wrappedValue: Output {
        get { getter() }
        set { subject.send(newValue) }
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
    
    public subscript<T>(_ keyPath: WritableKeyPath<Output, T>) -> Binding<T> {
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

    public subscript<T>(_ keyPath: WritableKeyPath<Output, Optional<T>>, default defaultValue: T) -> Binding<T> where Output == Optional<T> {
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
        let binding = Binding<T>(
            subject: subject,
            cancellable: nil,
            getter: {
                let root = rootGetter()
                return root[keyPath: keyPath] ?? defaultValue
            }
        )
        return binding
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Output, T>) -> Binding<T> {
        return self[keyPath]
    }
}



// MARK: - Avoid collision with another framework

public typealias UIBinding = Binding

