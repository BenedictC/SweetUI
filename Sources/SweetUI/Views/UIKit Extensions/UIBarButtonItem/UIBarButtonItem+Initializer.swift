import UIKit
import Combine


@available(iOS 14, *)
public extension UIBarButtonItem {

    convenience init(title: String? = nil, imageNamed imageName: String? = nil, action handler: @escaping () -> Void) {
        let action = UIAction { _ in handler() }
        let image = imageName.flatMap { UIImage(named: $0) }
        self.init(title: title, image: image, primaryAction: action)
    }

    convenience init(title: String? = nil, systemImageNamed imageName: String, action handler: @escaping () -> Void) {
        let action = UIAction { _ in handler() }
        let image = UIImage(systemName: imageName)
        self.init(title: title, image: image, primaryAction: action)
    }

    convenience init(systemItem: UIBarButtonItem.SystemItem, action handler: @escaping () -> Void) {
        let action = UIAction { _ in handler() }
        self.init(systemItem: systemItem, primaryAction: action, menu: nil)
    }

    convenience init(title: String? = nil, imageNamed imageName: String? = nil, action handler: @escaping (Self) -> Void) {
        let action = UIAction { handler(($0.sender as? Self)!) }
        let image = imageName.flatMap { UIImage(named: $0) }
        self.init(title: title, image: image, primaryAction: action)
    }

    convenience init(title: String? = nil, systemImageNamed imageName: String, action handler: @escaping (Self) -> Void) {
        let action = UIAction { handler(($0.sender as? Self)!) }
        let image = UIImage(systemName: imageName)
        self.init(title: title, image: image, primaryAction: action)
    }

    convenience init(systemItem: UIBarButtonItem.SystemItem, action handler: @escaping (Self) -> Void) {
        let action = UIAction { handler(($0.sender as? Self)!) }
        self.init(systemItem: systemItem, primaryAction: action, menu: nil)
    }

    convenience init(customView builder: () -> UIView) {
        let customView = builder()
        self.init(customView: customView)
    }
}


@available(iOS 15, *)
public extension UIBarButtonItem {

    func enabled<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isEnabled = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }

    func selected<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isSelected = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}


@available(iOS 16, *)
public extension UIBarButtonItem {

    func hidden<P: Publisher>(
        _ publisher: P,
        cancellableStorageHandler: CancellableStorageHandler = DefaultCancellableStorage.shared.store
    ) -> Self where P.Output == Bool, P.Failure == Never {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageHandler: cancellableStorageHandler)
        // So we have to do it the long way:
        let cancellable = publisher.sink { [weak self] value in
            self?.isHidden = value
        }
        cancellableStorageHandler(cancellable, self)
        return self
    }
}
