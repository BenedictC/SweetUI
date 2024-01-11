import Combine


// MARK: - State

/// OneWayBinding is a readonly publisher that also provides a getter
@propertyWrapper
@dynamicMemberLookup
public class OneWayBinding<Output>: Publisher {

    // MARK: Types

    public typealias Output = Output
    public typealias Failure = Never


    // MARK: Properties

    public var wrappedValue: Output { value }
    public var value: Output { getter() }

    let publisher: AnyPublisher<Output, Failure>
    let getter: () -> Output
    internal var cancellable: AnyCancellable?


    public init<P: Publisher>(publisher: P, get getter: @escaping () -> Output) where P.Output == Output, P.Failure == Never {
        self.publisher = publisher.eraseToAnyPublisher()
        self.getter = getter
    }

    public init(wrappedValue: Output) {
        self.publisher = Just(wrappedValue).eraseToAnyPublisher()
        self.getter = { wrappedValue }
    }


    // MARK: Subscript

    public subscript<T>(dynamicMember keyPath: KeyPath<Output, T>) -> OneWayBinding<T> {
        if keyPath == \T.self, let existing = self as? OneWayBinding<T> { return existing }
        let rootGetter = getter
        return OneWayBinding<T>(publisher: self.map { $0[keyPath: keyPath] }, get: { rootGetter()[keyPath: keyPath] })
    }


    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.subscribe(subscriber)
    }
}
