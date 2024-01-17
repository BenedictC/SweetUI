import Combine


public extension Publisher where Output == Bool {

    var inverted: AnyPublisher<Output, Failure> {
        self.map { !$0 }
            .eraseToAnyPublisher()
    }
}
