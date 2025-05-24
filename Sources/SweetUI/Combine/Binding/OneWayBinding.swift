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
public class OneWayBinding<Output>: Publisher {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never
    public typealias Options = BindingOptions


    // MARK: Properties

    public var wrappedValue: Output { getter() }

    internal let publisher: AnyPublisher<Output, Failure>
    internal let cancellable: AnyCancellable?
    internal let getter: () -> Output


    // MARK: Instance life cycle

    internal init(publisher: some Publisher<Output, Never>, cancellable: AnyCancellable?, get getter: @escaping () -> Output, options: Options = .default) {
        self.publisher = options.decorate(publisher).eraseToAnyPublisher()
        self.getter = getter
        self.cancellable = cancellable
    }

    public init(wrappedValue: Output, options: Options = .default) {
        let just = Just(wrappedValue)
        self.publisher = options.decorate(just).eraseToAnyPublisher()
        self.cancellable = nil
        self.getter = { just.output }
    }

    public init(currentValueSubject: CurrentValueSubject<Output, Never>, options: Options = .default) {
        self.publisher = options.decorate(currentValueSubject).eraseToAnyPublisher()
        self.cancellable = nil
        self.getter = { currentValueSubject.value }
    }


    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.subscribe(subscriber)
    }


    // MARK: Subscript

    public subscript<T>(_ keyPath: KeyPath<Output, T>) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> { return existing }

        let rootGetter = getter
        return OneWayBinding<T>(publisher: self.map { $0[keyPath: keyPath] }, cancellable: nil, get: { rootGetter()[keyPath: keyPath] })
    }

    public subscript<T>(_ keyPath: KeyPath<Output, T?>, default defaultValue: T) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> { return existing }

        let rootGetter = getter
        return OneWayBinding<T>(
            publisher: self.map { $0[keyPath: keyPath] ?? defaultValue },
            cancellable: nil,
            get: { rootGetter()[keyPath: keyPath] ?? defaultValue }
        )
    }
}


// MARK: - Factories

public extension Just {

    func makeOneWayBinding() -> OneWayBinding<Output> {
        OneWayBinding(publisher: self, cancellable: nil, get: { self.output })
    }
}


public extension CurrentValueSubject where Failure == Never {

    func makeOneWayBinding() -> OneWayBinding<Output> {
        OneWayBinding(currentValueSubject: self)
    }
}


public extension Publisher where Failure == Never {

    func makeOneWayBinding(initialValue: Output) -> OneWayBinding<Output> {
        var value = initialValue
        let publisher = self
        let cancellable = publisher.sink {
            value = $0
        }
        return OneWayBinding(publisher: publisher, cancellable: cancellable, get: { value })
    }
}
