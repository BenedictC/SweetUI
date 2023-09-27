import Combine


// MARK: - State

/// OneWayBinding is a readonly publisher that also provides a getter
@propertyWrapper
public struct OneWayBinding<Output>: Publisher {

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


    // MARK: Publisher

    public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, Output == S.Input {
        publisher.subscribe(subscriber)
    }
}

public extension OneWayBinding {

    init(wrappedValue: Output) {
        self.init(publisher: Just(wrappedValue), get: { wrappedValue })
    }
}