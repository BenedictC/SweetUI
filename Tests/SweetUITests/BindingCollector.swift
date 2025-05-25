import SweetUI


class BindingCollector<T> {

    struct Received {
        let value: T
        let onMainThread: Bool

        static func make(_ value: T, _ onMainThread: Bool) -> Self {
            Received(value: value, onMainThread: onMainThread)
        }
    }

    private(set) var collected = [Received]()
    var collectedValues: [T] { collected.map { $0.value } }

    private var cancellable: AnyCancellable?

    init(binding: OneWayBinding<T>) {
        cancellable = binding.sink { [weak self] value in
            let received = Received(value: value, onMainThread: Thread.isMainThread)
            self?.collected.append(received)
        }
    }

    func cancel() {
        cancellable?.cancel()
    }
}


extension BindingCollector.Received: Equatable where T: Equatable {

}
