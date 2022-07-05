import Combine


public extension Publisher where Output: Equatable {

    func onReceive(_ value: Output, handler: @escaping () -> Void) -> AnyCancellable where Failure == Never {
        sink {
            if value == $0 {
                handler()
            }
        }
    }
}



public extension Publisher {

    func optionalMap() -> Publishers.Map<Self, Self.Output?> {
        map(Optional.some)
    }
}
