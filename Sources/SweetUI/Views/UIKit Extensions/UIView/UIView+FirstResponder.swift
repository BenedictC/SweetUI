import UIKit
import Combine

public typealias FirstResponderState<T: Hashable> = Binding<T>


public extension UIView {

    func firstResponder<F: Hashable>(
        when publisher: FirstResponderState<F>,
        isEqualTo targetValue: F,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self {
        return firstResponder(when: publisher.map { $0 == targetValue })
    }

    func firstResponder<P: Publisher>(
        when publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == Bool, P.Failure == Never {
        let cancellable = publisher.sink { [weak self] isFirstResponder in
            guard isFirstResponder,
            let self else { return }
            self.becomeFirstResponder()
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}
