import Combine


public extension Publisher where Output == Bool {

    var inverted: AnyPublisher<Output, Failure> {
        self.map { !$0 }
            .eraseToAnyPublisher()
    }
}


public prefix func !<P: Publisher>(publisher: P) -> AnyPublisher<Bool, P.Failure> where P.Output == Bool {
    publisher.inverted
}
