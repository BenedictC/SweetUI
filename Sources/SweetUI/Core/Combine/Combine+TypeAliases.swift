import Combine


public typealias ViewBinding<T> = AnySubject<T, Never>
public typealias ViewState<T> = AnyPublisher<T, Never>

