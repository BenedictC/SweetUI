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


    // TODO: Make a two-way binding look up graph. Is it even possible?
//    // MARK: Dynamic member lookup (for creating binding to reference types)
//
//    public subscript<T>(dynamicMember bindingKeyPath: KeyPath<Output, some OneWayBinding<T>>) -> OneWayBinding<T> {
//        if bindingKeyPath == \T.self, let existing = self as? OneWayBinding<T> {
//            return existing
//        }
//        // Create the initial state
//        let initialValue = self.value[keyPath: bindingKeyPath].value
//        let subject = CurrentValueSubject<T, Never>(initialValue)
//        let result = OneWayBinding<T>(currentValueSubject: subject, options: .default)
//
//        var previousCancellable: AnyCancellable?
//        // when self emits a new value ...
//        let cancellable = self.sink { [weak result] rootObject in
//            _ = self // retain the previous Binding but don't retain the output as that would great a retain cycle
//            guard let result else {
//                return
//            }
//            // ... we need to re-construct the value we were binding to
//            let childBinding = rootObject[keyPath: bindingKeyPath]
//            if let previousCancellable {
//                result.cancellables.remove(previousCancellable)
//                previousCancellable.cancel()
//            }
//            let freshCancellable = childBinding.sink { childObject in
//                subject.send(childObject)
//            }
//            result.cancellables.insert(freshCancellable)
//            previousCancellable = freshCancellable
//            // Send the child this may have already occured
//            let updatedChild = rootObject[keyPath: bindingKeyPath].value
//            subject.send(updatedChild)
//        }
//        result.cancellables.insert(cancellable)
//
//        return result
//    }
}


// MARK: - KeyPath based sub-bindings (for value types)

// TODO: Make a two-way binding look up graph. Is it even possible?
//public extension OneWayBinding {
//
//    subscript<T>(oneWay keyPath: KeyPath<Output, T>) -> OneWayBinding<T> {
//        if keyPath == \T.self, let existing = self as? OneWayBinding<T> {
//            return existing
//        }
//
//        let rootGetter = getter
//        return OneWayBinding<T>(
//            publisher: self.map { $0[keyPath: keyPath] },
//            get: { rootGetter()[keyPath: keyPath] }
//        )
//    }
//
//    subscript<T>(oneWay keyPath: KeyPath<Output, T?>, default defaultValue: T) -> OneWayBinding<T> {
//        if keyPath == \T.self, let existing = self as? OneWayBinding<T> {
//            return existing
//        }
//
//        let rootGetter = getter
//        return OneWayBinding<T>(
//            publisher: self.map { $0[keyPath: keyPath] ?? defaultValue },
//            get: { rootGetter()[keyPath: keyPath] ?? defaultValue }
//        )
//    }
//}
//
//
//// Allow leading `.?.` to be dropped when self is optional
//
//public extension OneWayBinding where Output: _Optionalable {
//
//    subscript<T>(oneWay keyPath: KeyPath<Output.Wrapped, T>) -> OneWayBinding<T?> {
//        let rootGetter = getter
//        return OneWayBinding<T?>(
//            publisher: self.map { value in
//                value[keyPath: \Output.asOptional]?[keyPath: keyPath]
//            },
//            get: { rootGetter()[keyPath: \Output.asOptional]?[keyPath: keyPath] }
//        )
//    }
//
//    subscript<T>(oneWay keyPath: KeyPath<Output.Wrapped, T?>, default defaultValue: T) -> OneWayBinding<T> {
//        let rootGetter = getter
//        return OneWayBinding<T>(
//            publisher: self.map { value in
//                value[keyPath: \Output.asOptional]?[keyPath: keyPath] ?? defaultValue
//            },
//            get: { rootGetter()[keyPath: \Output.asOptional]?[keyPath: keyPath] ?? defaultValue }
//        )
//    }
//}


// MARK: - Avoid collision with another framework

public typealias UIBinding = Binding



// MARK: - Subscripts

public extension Binding {

//    subscript<T>(_ keyPath: WritableKeyPath<Output, T>) -> Binding<T> {
//        if keyPath == \.self, let existing = self as? Binding<T> { return existing }
//
//        let rootSubject = subject
//        let rootGetter = getter
//        let setter = { (newValue: T) in
//            var rootValue = rootGetter()
//            rootValue[keyPath: keyPath] = newValue
//            rootSubject.send(rootValue)
//        }
//        let subject = AnySubject(
//            get: publisher.map { $0[keyPath: keyPath] },
//            set: setter
//        )
//        fatalError()
//        """
//        let binding = Binding<T>(
//            subject: subject,
//            getter: {
//                let root = rootGetter()
//                return root[keyPath: keyPath]
//            }
//        )
//        return binding
//        """
//    }
//
//    subscript<T>(_ keyPath: WritableKeyPath<Output, Optional<T>>, default defaultValue: T) -> Binding<T> {
//        if keyPath == \.self, let existing = self as? Binding<T> { return existing }
//
//        let rootSubject = subject
//        let rootGetter = getter
//        let setter = { (newValue: T) in
//            var rootValue = rootGetter()
//            rootValue[keyPath: keyPath] = newValue
//            rootSubject.send(rootValue)
//        }
//        let subject = AnySubject(
//            get: publisher.map { $0[keyPath: keyPath] ?? defaultValue },
//            set: setter
//        )
//        fatalError()
//        """
//        let binding = Binding<T>(
//            subject: subject,
//            getter: {
//                let root = rootGetter()
//                return root[keyPath: keyPath] ?? defaultValue
//            }
//        )
//        return binding
//        """
//    }
}
