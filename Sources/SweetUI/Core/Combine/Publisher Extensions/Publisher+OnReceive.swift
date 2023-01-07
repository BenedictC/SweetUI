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
