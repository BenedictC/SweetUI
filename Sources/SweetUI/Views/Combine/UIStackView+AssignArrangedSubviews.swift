import UIKit
import Combine


public extension SomeView where Self: UIStackView {

    func assignArrangedSubviews<C: CancellablesStorageProvider, P: Publisher, V: UIView>(from subscriberFactory: SubscriberFactory<C, P>) -> Self where P.Failure == Never, P.Output == ([V]?) {
        subscriberFactory.makeSubscriber(with: self) { stackView, _, views in
            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            views?.forEach { stackView.addArrangedSubview($0) }
        }
        return self
    }
}
