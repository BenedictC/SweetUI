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

    public var value: Output { getter() }

    internal let publisher: AnyPublisher<Output, Failure>
    internal lazy var cancellables = Set<AnyCancellable>()
    internal let getter: () -> Output


    // MARK: Instance life cycle

    public init(currentValueSubject: CurrentValueSubject<Output, Never>, options: BindingOptions = .default) {
        self.publisher = options.decorate(currentValueSubject).eraseToAnyPublisher()
        self.getter = { currentValueSubject.value }
    }

    public init(wrappedValue: Output, options: BindingOptions = .default) {
        let just = Just(wrappedValue)
        self.publisher = options.decorate(just).eraseToAnyPublisher()
        self.getter = { just.output }
    }

    internal init(publisher: some Publisher<Output, Never>, get getter: @escaping () -> Output, options: BindingOptions = .default) {
        self.publisher = options.decorate(publisher).eraseToAnyPublisher()
        self.getter = getter
    }


    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.subscribe(subscriber)
    }


    // MARK: Dynamic Member Lookup

    public subscript<T>(dynamicMember keyPath: KeyPath<Output, some OneWayBinding<T>>) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> {
            return existing
        }
        // Create the initial state
        let initialValue = self.value[keyPath: keyPath].value
        let subject = CurrentValueSubject<T, Never>(initialValue)
        let result = OneWayBinding<T>(currentValueSubject: subject, options: .default)

        var previousCancellable: AnyCancellable?
        // when self emits a new value ...
        let cancellable = self.sink { [weak result] root in
            _ = self // retain the previous Binding
            guard let result else {
                return
            }
            // ... we need to re-construct the value we were binding to
            let publisher = root[keyPath: keyPath]
            if let previousCancellable {
                result.cancellables.remove(previousCancellable)
                previousCancellable.cancel()
            }
            let freshCancellable = publisher.sink { subject.send($0) }
            result.cancellables.insert(freshCancellable)
            previousCancellable = freshCancellable
        }
        result.cancellables.insert(cancellable)

        return result
    }


    // MARK: Subscript

    public subscript<T>(oneWay keyPath: KeyPath<Output, T>) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> { return existing }

        let rootGetter = getter
        return OneWayBinding<T>(
            publisher: self.map { $0[keyPath: keyPath] },
            get: { rootGetter()[keyPath: keyPath] }
        )
    }

    public subscript<T>(oneWay keyPath: KeyPath<Output, T?>, default defaultValue: T) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> { return existing }

        let rootGetter = getter
        return OneWayBinding<T>(
            publisher: self.map { $0[keyPath: keyPath] ?? defaultValue },
            get: { rootGetter()[keyPath: keyPath] ?? defaultValue }
        )
    }

    public subscript<T>(oneWay keyPath: KeyPath<Output.Wrapped, T>) -> OneWayBinding<T?> where Output: _Optionalable {
//        if keyPath == \T.self, let existing = self as? OneWayBinding<T> {
//            return existing
//        }

        let rootGetter = getter
        return OneWayBinding<T?>(
            publisher: self.map { value in
                value[keyPath: \Output.asOptional]?[keyPath: keyPath]
            },
            get: { rootGetter()[keyPath: \Output.asOptional]?[keyPath: keyPath] }
        )
    }
}

@available(*, deprecated)
private var _cancellables = Set<AnyCancellable>()


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
