import Combine


public struct BindingOptions: OptionSet {
    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static var dropDuplicates: Self { Self(rawValue: 1 << 0) }
    public static var bounceToMainThread: Self { Self(rawValue: 1 << 1) }
    public static var `default`: Self { [.dropDuplicates, .bounceToMainThread] }
}


/// OneWayBinding is a readonly publisher that also provides a getter. It is the base class for the Bindings class cluster.
@dynamicMemberLookup
public class OneWayBinding<Output>: Publisher {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never


    // MARK: Properties

    // ProjectedValue and WrappedValue are handled by leaves of the cluster which conform to @propertyWrapper,
    // i.e. Binding and Binding.OneWay

    public let options: BindingOptions
    public var value: Output { getter() }

    internal let publisher: AnyPublisher<Output, Failure>
    internal lazy var cancellables = Set<AnyCancellable>()
    internal let getter: () -> Output


    // MARK: Instance life cycle

    public init(currentValueSubject: CurrentValueSubject<Output, Never>, options: BindingOptions = .default) {
        self.options = options
        self.publisher = options.decorate(currentValueSubject).eraseToAnyPublisher()
        self.getter = { currentValueSubject.value }
    }

    public init(wrappedValue: Output, options: BindingOptions = .default) {
        self.options = options
        let just = Just(wrappedValue)
        self.publisher = options.decorate(just).eraseToAnyPublisher()
        self.getter = { just.output }
    }

    internal init(publisher: some Publisher<Output, Never>, get getter: @escaping () -> Output, options: BindingOptions = .default) {
        self.options = options
        self.publisher = options.decorate(publisher).eraseToAnyPublisher()
        self.getter = getter
    }


    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.subscribe(subscriber)
    }


    // MARK: Dynamic member lookup (for creating binding to reference types)

    public subscript<T>(dynamicMember bindingKeyPath: KeyPath<Output, some OneWayBinding<T>>) -> OneWayBinding<T> {
        if bindingKeyPath == \T.self, let existing = self as? OneWayBinding<T> {
            return existing
        }
        // Create the initial state
        let initialValue = self.value[keyPath: bindingKeyPath].value
        let subject = CurrentValueSubject<T, Never>(initialValue)
        let result = OneWayBinding<T>(currentValueSubject: subject, options: self.options)

        var previousCancellable: AnyCancellable?
        // when self emits a new value ...
        let cancellable = self.sink { [weak result] rootObject in
            _ = self // retain the previous Binding but don't retain the output as that would great a retain cycle
            guard let result else {
                return
            }
            // ... we need to re-construct the value we were binding to
            let childBinding = rootObject[keyPath: bindingKeyPath]
            if let previousCancellable {
                result.cancellables.remove(previousCancellable)
                previousCancellable.cancel()
            }
            let freshCancellable = childBinding.sink { childObject in
                subject.send(childObject)
            }
            result.cancellables.insert(freshCancellable)
            previousCancellable = freshCancellable
            // Send the child this may have already occurred
            let updatedChild = rootObject[keyPath: bindingKeyPath].value
            subject.send(updatedChild)
        }
        result.cancellables.insert(cancellable)

        return result
    }

    public subscript<T>(dynamicMember publisherKeyPath: KeyPath<Output, Published<T>.Publisher>) -> OneWayBinding<T> {
        // Create the initial state
        let childPublisher = self.value[keyPath: publisherKeyPath]
        var initialValue: T!
        let initialCancellable = childPublisher.sink { initialValue = $0 }

        if let initialValue {
            initialCancellable.cancel()
            let subject = CurrentValueSubject<T, Never>(initialValue)
            let result = OneWayBinding<T>(currentValueSubject: subject, options: self.options)

            var previousCancellable: AnyCancellable?
            // when self emits a new value ...
            let cancellable = self.sink { [weak result] rootObject in
                _ = self // retain the previous Binding but don't retain the output as that would great a retain cycle
                guard let result else {
                    return
                }
                // ... we need to re-construct the value we were binding to
                let childBinding = rootObject[keyPath: publisherKeyPath]
                if let previousCancellable {
                    result.cancellables.remove(previousCancellable)
                    previousCancellable.cancel()
                }
                let freshCancellable = childBinding.sink { childObject in
                    subject.send(childObject)
                }
                result.cancellables.insert(freshCancellable)
                previousCancellable = freshCancellable
            }
            result.cancellables.insert(cancellable)
            return result
        } else {
            // It would be very strange if publisher immediately supply a value but it's possible according to
            // the api contract. This is untested.
            initialCancellable.cancel()
            var currentValue: T!
            let subject = PassthroughSubject<T, Never>()
            let result = OneWayBinding<T>(publisher: subject, get: { currentValue }, options: self.options)

            var previousCancellable: AnyCancellable?
            // when self emits a new value ...
            let cancellable = self.sink { [weak result] rootObject in
                _ = self // retain the previous Binding but don't retain the output as that would great a retain cycle
                guard let result else {
                    return
                }
                // ... we need to re-construct the value we were binding to
                let childPublisher = rootObject[keyPath: publisherKeyPath]
                if let previousCancellable {
                    result.cancellables.remove(previousCancellable)
                    previousCancellable.cancel()
                }
                let freshCancellable = childPublisher.sink { childObject in
                    subject.send(childObject)
                    // Set after sending so that the old value is still accessible in sinks
                    currentValue = childObject
                }
                result.cancellables.insert(freshCancellable)
                previousCancellable = freshCancellable
            }
            result.cancellables.insert(cancellable)
            return result
        }
    }
}


// MARK: - KeyPath based sub-bindings (for value types)

public extension OneWayBinding {

    subscript<T>(oneWay keyPath: KeyPath<Output, T>) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> {
            return existing
        }

        let rootGetter = getter
        return OneWayBinding<T>(
            publisher: self.map { $0[keyPath: keyPath] },
            get: { rootGetter()[keyPath: keyPath] }
        )
    }

    subscript<T: _Optionalable>(oneWay keyPath: KeyPath<Output, T>, default defaultValue: T.Wrapped) -> OneWayBinding<T.Wrapped> {
        func fetchAndUnwrap(root: Output) -> T.Wrapped {
            let anyValue = root[keyPath: keyPath] as Any?
            let anyFlattenedValue = anyValue.flattened() as? T.Wrapped?

            if let flattendValue = anyFlattenedValue {
                return flattendValue ?? defaultValue
            } else {
                return defaultValue
            }
        }
        
        let rootGetter = getter
        return OneWayBinding<T.Wrapped>(
            publisher: self.map { root in
                fetchAndUnwrap(root: root)
            },
            get: {
                fetchAndUnwrap(root: rootGetter())
            }
        )
    }
}


// Allow leading `.?.` to be dropped when self is optional

public extension OneWayBinding where Output: _Optionalable {

    subscript<T>(oneWay keyPath: KeyPath<Output.Wrapped, T>) -> OneWayBinding<T?> {
        let rootGetter = getter
        return OneWayBinding<T?>(
            publisher: self.map { value in
                value[keyPath: \Output.asOptional]?[keyPath: keyPath]
            },
            get: { rootGetter()[keyPath: \Output.asOptional]?[keyPath: keyPath] }
        )
    }

    subscript<T: _Optionalable>(oneWay keyPath: KeyPath<Output.Wrapped, T>, default defaultValue: T.Wrapped) -> OneWayBinding<T.Wrapped> {
        let rootGetter = getter
        return OneWayBinding<T.Wrapped>(
            publisher: self.map { value in
                value[keyPath: \Output.asOptional]?[keyPath: keyPath].asOptional ?? defaultValue
            },
            get: {
                let root: Output.Wrapped? = rootGetter().asOptional
                let value = root?[keyPath: keyPath].asOptional
                return value.asOptional ?? defaultValue
            }
        )
    }

    subscript<T>(oneWay keyPath: KeyPath<Output.Wrapped, T?>) -> OneWayBinding<T?> {
        let rootGetter = getter
        return OneWayBinding<T?>(
            publisher: self.map { value in
                value[keyPath: \Output.asOptional]?[keyPath: keyPath]
            },
            get: { rootGetter()[keyPath: \Output.asOptional]?[keyPath: keyPath] }
        )
    }

    subscript<T>(oneWay keyPath: KeyPath<Output.Wrapped, T?>, default defaultValue: T) -> OneWayBinding<T> {
        let rootGetter = getter
        return OneWayBinding<T>(
            publisher: self.map { value in
                value[keyPath: \Output.asOptional]?[keyPath: keyPath] ?? defaultValue
            },
            get: { rootGetter()[keyPath: \Output.asOptional]?[keyPath: keyPath] ?? defaultValue }
        )
    }
}


// MARK: - Factories

public extension Just {

    func makeOneWayBinding() -> OneWayBinding<Output> {
        OneWayBinding(publisher: self,/* cancellable: nil,*/ get: { self.output })
    }
}


public extension CurrentValueSubject where Failure == Never {

    func makeOneWayBinding(options: BindingOptions = .default) -> OneWayBinding<Output> {
        OneWayBinding(currentValueSubject: self, options: options)
    }
}


public extension Publisher where Failure == Never {

    // This is ugly.
    // We need an initial value but we can't be sure that the publisher will provide one so we have to request it.
    func makeOneWayBinding(initialValue: Output, options: BindingOptions = .default) -> OneWayBinding<Output> {
        var value = initialValue
        let publisher = self
        let cancellable = publisher.sink {
            value = $0
        }
        let binding = OneWayBinding(publisher: publisher, get: { value }, options: options)
        binding.cancellables.insert(cancellable)
        return binding
    }
}
