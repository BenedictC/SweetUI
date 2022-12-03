import Combine


public typealias ViewBinding<T> = AnySubject<T, Never>
public typealias ViewState<T> = AnyPublisher<T, Never>


// MARK: -

@propertyWrapper
public struct State<T> {

    public var wrappedValue: T {
        get { subject.value }
        set { subject.send(newValue) }
    }

    public let projectedValue: AnyPublisher<T, Never>
    private let subject: CurrentValueSubject<T, Never>

    public init(wrappedValue: T) {
        subject = CurrentValueSubject(wrappedValue)
        projectedValue = subject.eraseToAnyPublisher()
    }
}


@propertyWrapper
public struct Binding<T> {

    public var wrappedValue: T {
        get { subject.value }
        set { subject.send(newValue) }
    }

    public let projectedValue: AnySubject<T, Never>
    private let subject: CurrentValueSubject<T, Never>

    public init(wrappedValue: T) {
        subject = CurrentValueSubject(wrappedValue)
        projectedValue = subject.eraseToAnySubject()
    }
}
