import Foundation
import Combine


// MARK: - Cancellables

public class PublisherAssignmentProxy<T: AnyObject> {

    weak var origin: T?

    init(origin: T) {
        self.origin = origin
    }
}


public extension Publisher {

    func assign<T>(to keyPath: ReferenceWritableKeyPath<T, Output>, on proxy: PublisherAssignmentProxy<T>) -> AnyCancellable where Failure == Never {
        self.sink { proxy.origin?[keyPath: keyPath] = $0 }
    }
}


public extension ViewControlling where Self: _ViewController { // TODO: Should this be an extension on a more widely applicable protocol?

    func collectCancellables(for key: AnyHashable = UUID().uuidString, @CancellablesBuilder using cancellableBuilder: () -> AnyCancellable) {
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder() }
        storeCancellable(cancellable, for: key)
    }

    func collectCancellables(for key: AnyHashable = UUID().uuidString, @CancellablesBuilder using cancellableBuilder: (PublisherAssignmentProxy<Self>) -> AnyCancellable) {
        let proxy = PublisherAssignmentProxy(origin: self)
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder(proxy) }
        storeCancellable(cancellable, for: key)
    }
}
