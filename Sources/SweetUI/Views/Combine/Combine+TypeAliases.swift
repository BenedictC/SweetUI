import Combine


public typealias ViewBinding<T> = CurrentValueSubject<T, Never>
#if swift(<5.7)
public typealias ViewState<T> = AnyPublisher<T, Never>
#else
public typealias ViewState<T> = any Publisher<T, Never>
#endif


// MARK: - Helper

public extension CurrentValueSubject {

    func send(using transform: (inout Output) -> Void) {
        var value = self.value
        transform(&value)
        self.send(value)
    }

    func send(using transform: (Output) -> Output) {
        let stale = self.value
        let fresh = transform(stale)
        self.send(fresh)
    }
}
