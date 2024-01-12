import Combine


/// OneWayBinding is a readonly publisher that also provides a getter
@propertyWrapper
@dynamicMemberLookup
public class OneWayBinding<Output>: Publisher {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never


    // MARK: Properties

    public var wrappedValue: Output { getter() }

    internal let publisher: AnyPublisher<Output, Failure>
    internal let cancellable: AnyCancellable?
    internal let getter: () -> Output


    // MARK: Instance life cycle

    internal init<P: Publisher>(publisher: P, cancellable: AnyCancellable?, get getter: @escaping () -> Output) where P.Output == Output, P.Failure == Never {
        self.publisher = publisher as? AnyPublisher<Output, Never> ?? publisher.eraseToAnyPublisher()
        self.getter = getter
        self.cancellable = cancellable
    }

    public init(wrappedValue: Output) {
        let just = Just(wrappedValue)
        self.publisher = just.eraseToAnyPublisher()
        self.cancellable = nil
        self.getter = { just.output }
    }

    public init(currentValueSubject: CurrentValueSubject<Output, Never>) {
        self.publisher = currentValueSubject.eraseToAnyPublisher()
        self.cancellable = nil
        self.getter = { currentValueSubject.value }
    }


    // MARK: Subscript

    public subscript<T>(dynamicMember keyPath: KeyPath<Output, T>) -> OneWayBinding<T> {
        return self[binding: keyPath]
    }

    public subscript<T>(binding keyPath: KeyPath<Output, T>) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> { return existing }

        let rootGetter = getter
        return OneWayBinding<T>(publisher: self.map { $0[keyPath: keyPath] }, cancellable: nil, get: { rootGetter()[keyPath: keyPath] })
    }


    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.subscribe(subscriber)
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
