import Combine


// MARK: -

public protocol _Optionalable {
    associatedtype Wrapped
}


extension Optional: _Optionalable { }


extension _Optionalable {

    internal var asOptional: Optional<Wrapped> {
        self as! Optional<Wrapped>
    }
}


protocol Flattenable {
    func flattened() -> Any?
}

extension Optional: Flattenable {
    func flattened() -> Any? {
        switch self {
        case .some(let x as Flattenable): return x.flattened()
        case .some(let x): return x
        case .none: return nil
        }
    }
}



// MARK: - Nil checks

public extension Publisher where Output: _Optionalable {

    var isNil: some Publisher<Bool, Failure> {
        map { $0.asOptional == nil }
    }

    var isNotNil: some Publisher<Bool, Failure> {
        map { $0.asOptional != nil }
    }
}
