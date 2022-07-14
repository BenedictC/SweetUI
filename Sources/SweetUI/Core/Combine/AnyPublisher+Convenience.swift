import Combine


public extension AnyPublisher {

    init<P: Publisher>(_ builder: () -> P) where P.Output == Output, P.Failure == Failure {
        let publisher = builder()
        self.init(publisher)
    }
}
