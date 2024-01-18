import Combine


// MARK: - Static values

public extension Publisher where Output: Equatable {

    func isEqualTo(_ value: Output) -> AnyPublisher<Bool, Failure> {
        map { $0 == value }.eraseToAnyPublisher()
    }

    func isNotEqualTo(_ value: Output) -> AnyPublisher<Bool, Failure> {
        map { $0 != value }.eraseToAnyPublisher()
    }
}


public extension Publisher where Output: Comparable {

    func isLessThan(_ value: Output) -> AnyPublisher<Bool, Failure> {
        map { $0 < value }.eraseToAnyPublisher()
    }

    func isGreaterThan(_ value: Output) -> AnyPublisher<Bool, Failure> {
        map { $0 > value }.eraseToAnyPublisher()
    }

    func isLessThanOrEqualTo(_ value: Output) -> AnyPublisher<Bool, Failure> {
        map { $0 <= value }.eraseToAnyPublisher()
    }

    func isGreaterThanOrEqualTo(_ value: Output) -> AnyPublisher<Bool, Failure> {
        map { $0 >= value }.eraseToAnyPublisher()
    }
}


// MARK: - Publishers

public extension Publisher where Output: Equatable {

    func isEqualTo<P: Publisher>(_ other: P) -> AnyPublisher<Bool, Failure> where P.Output == Output, P.Failure == Failure {
        combineLatest(other)
            .map { $0.0 == $0.1 }
            .eraseToAnyPublisher()
    }

    func isNotEqualTo<P: Publisher>(_ other: P) -> AnyPublisher<Bool, Failure> where P.Output == Output, P.Failure == Failure {
        combineLatest(other)
            .map { $0.0 != $0.1 }
            .eraseToAnyPublisher()
    }
}


public extension Publisher where Output: Comparable {

    func isLessThan<P: Publisher>(_ other: P) -> AnyPublisher<Bool, Failure> where P.Output == Output, P.Failure == Failure {
        combineLatest(other)
            .map { $0.0 < $0.1 }
            .eraseToAnyPublisher()
    }

    func isGreaterThan<P: Publisher>(_ other: P) -> AnyPublisher<Bool, Failure> where P.Output == Output, P.Failure == Failure {
        combineLatest(other)
            .map { $0.0 > $0.1 }
            .eraseToAnyPublisher()
    }

    func isLessThanOrEqualTo<P: Publisher>(_ other: P) -> AnyPublisher<Bool, Failure> where P.Output == Output, P.Failure == Failure {
        combineLatest(other)
            .map { $0.0 <= $0.1 }
            .eraseToAnyPublisher()
    }

    func isGreaterThanOrEqualTo<P: Publisher>(_ other: P) -> AnyPublisher<Bool, Failure> where P.Output == Output, P.Failure == Failure {
        combineLatest(other)
            .map { $0.0 >= $0.1 }
            .eraseToAnyPublisher()
    }
}
