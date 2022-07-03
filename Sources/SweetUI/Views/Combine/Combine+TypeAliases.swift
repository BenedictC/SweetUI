import Combine


public typealias ViewBinding<T> = CurrentValueSubject<T, Never>
#if swift(<5.7)
public typealias ViewState<T> = AnyPublisher<T, Never>
#else
public typealias ViewState<T> = any Publisher<T, Never>
#endif
