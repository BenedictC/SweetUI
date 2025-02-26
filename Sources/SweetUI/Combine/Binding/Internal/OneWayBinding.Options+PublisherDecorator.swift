import Foundation
import Combine


// MARK: - BindingOptions+PublisherDecorator

internal extension OneWayBinding.Options {

    func decorate(_ publisher: some Publisher<Output, Never>) -> some Publisher<Output, Never> {
        var result = publisher.eraseToAnyPublisher()
        if self.contains(.removesDuplicates) {
            result = result
                .unconstrainedRemoveDuplicates()
                .eraseToAnyPublisher()
        }
        if self.contains(.bounceToMainThread) {
            result = result
                .switchToMainThreadIfNeeded()
                .eraseToAnyPublisher()
        }
        return result
    }
}


// MARK: - UnconstrainedRemoveDuplicates

internal extension Publisher {

    func unconstrainedRemoveDuplicates() -> some Publisher<Output, Failure> {
        guard Output.self is any Equatable.Type else {
            return self.eraseToAnyPublisher()
        }
        return self
            .removeDuplicates { stale, fresh in
                guard let staleEq = stale as? any Equatable,
                      let freshEq = fresh as? any Equatable else {
                    return false
                }
                return staleEq.isEqual(freshEq)
            }
            .eraseToAnyPublisher()
    }
}


internal extension Equatable {

    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}


// MARK: - SwitchToMainQueueIfNeededPublisher

internal struct SwitchToMainQueueIfNeededPublisher<Upstream: Publisher>: Publisher {

    // MARK: Types

    typealias Output = Upstream.Output
    typealias Failure = Upstream.Failure

    private class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {

        private var subscriber: S?
        private var remaining = Subscribers.Demand.none
        private let upstream: Upstream
        private var cancellable: AnyCancellable?


        init(subscriber: S, upstream: Upstream) {
            self.subscriber = subscriber
            self.upstream = upstream
        }

        func request(_ demand: Subscribers.Demand) {
            self.remaining = demand
            if cancellable != nil { return }

            let queue = DispatchQueue(label: "SweetUI.SwitchToMainQueueIfNeededPublisher", target: DispatchQueue.main)
            cancellable = upstream.sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.subscriber?.receive(completion: .finished)
                case .failure(let error):
                    self?.subscriber?.receive(completion: .failure(error))
                }
                self?.subscriber = nil

            }, receiveValue: { [weak self] value in
                guard let self, self.remaining > .none, let subscriber = self.subscriber else {
                    self?.subscriber?.receive(completion: .finished)
                    self?.cancel()
                    return
                }
                if Thread.isMainThread {
                    self.remaining += subscriber.receive(value)
                } else {
                    queue.async {
                        self.remaining += subscriber.receive(value)
                    }
                }
            })
        }

        func cancel() {
            subscriber = nil
            cancellable?.cancel()
        }
    }


    // MARK: Properties

    let upstream: Upstream


    // MARK: Instance life cycle

    init(upstream: Upstream) {
        self.upstream = upstream
    }


    // MARK: Publisher

    func receive(subscriber: some Subscriber<Output, Failure>) {
        let subscription = Subscription(subscriber: subscriber, upstream: upstream)
        subscriber.receive(subscription: subscription)
    }
}


internal extension Publisher {

    func switchToMainThreadIfNeeded() -> SwitchToMainQueueIfNeededPublisher<Self> {
        SwitchToMainQueueIfNeededPublisher(upstream: self)
    }
}
