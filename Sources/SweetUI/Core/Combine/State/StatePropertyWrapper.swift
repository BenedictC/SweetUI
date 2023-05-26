import Combine


// MARK: - State

// The only difference between State and Combine.Published is the type of projectedValue. Published uses a nested publisher, State uses AnyPublisher.

@propertyWrapper
public struct State<T> {

    public var wrappedValue: T {
        get { subject.value }
        // nonmutating is to avoid crashes due to re-entrant when the get is called by a subscriber of the underlying subject
        nonmutating
        set { subject.send(newValue) }
    }

    public let projectedValue: AnyPublisher<T, Never>
    private let subject: CurrentValueSubject<T, Never>

    public init(wrappedValue: T) {
        subject = CurrentValueSubject(wrappedValue)
        projectedValue = subject.eraseToAnyPublisher()
    }
}


// MARK: - Typealias for variable types

public typealias ViewState<T> = AnyPublisher<T, Never>
