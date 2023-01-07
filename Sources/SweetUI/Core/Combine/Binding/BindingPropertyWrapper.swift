import Combine


// MARK: - Binding

@propertyWrapper
public struct Binding<T> {

    public var wrappedValue: T {
        get { subject.value }
        // nonmutating is to avoid crashes due to re-entrant when the get is called by a subscriber of the underlying subject
        nonmutating
        set { subject.send(newValue) }
    }

    public let projectedValue: AnySubject<T, Never>
    private let subject: CurrentValueSubject<T, Never>

    public init(wrappedValue: T) {
        subject = CurrentValueSubject(wrappedValue)
        projectedValue = subject.eraseToAnySubject()
    }
}


// MARK: - Typealias for variable types

public typealias ViewBinding<T> = AnySubject<T, Never>
