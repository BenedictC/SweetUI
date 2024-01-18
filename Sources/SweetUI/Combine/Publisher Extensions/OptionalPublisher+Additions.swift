import Combine


// MARK: -

public protocol _Optionalable {
    associatedtype Wrapped
}


extension Optional: _Optionalable { }


extension _Optionalable {

    fileprivate var asOptional: Optional<Wrapped> {
        self as! Optional<Wrapped>
    }
}


// MARK: - Nil checks

public extension Publisher where Output: _Optionalable {

    var isNil: AnyPublisher<Bool, Failure> {
        map { $0.asOptional == nil }.eraseToAnyPublisher()
    }

    var isNotNil: AnyPublisher<Bool, Failure> {
        map { $0.asOptional != nil }.eraseToAnyPublisher()
    }
}
