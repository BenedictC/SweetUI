import UIKit
import Combine


public extension SomeView where Self: UIStackView {

    func assignArrangedSubviews<P: Publisher, V: UIView>(
        from publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared)
    -> Self where P.Failure == Never, P.Output == ([V]?) {
        let stackView = self
        let cancellable = publisher.sink { [weak stackView] views in
            guard let stackView else { return }
            // TODO: Do we need to implement a smart approach to this or will the stackView take care of it?
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            views?.forEach { stackView.addArrangedSubview($0) }
        }
        cancellableStorageProvider.storeCancellable(cancellable, forKey: .unique(for: self))
        return self
    }
}
