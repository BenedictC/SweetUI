import UIKit
import Combine


public extension UIBarButtonItem {

    func width(_ publisher: some Publisher<CGFloat, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.width = value
        }
        .store(in: .current)
        return self
    }
}


@available(iOS 14, *)
public extension UIBarButtonItem {

    func menu(_ publisher: some Publisher<UIMenu?, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            _ = self?.menu(value)
        }
        .store(in: .current)
        return self
    }
}


@available(iOS 15, *)
public extension UIBarButtonItem {

    func selected(_ publisher: some Publisher<Bool, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.isSelected = value
        }
        .store(in: .current)        
        return self
    }
}


@available(iOS 16, *)
public extension UIBarButtonItem {

    func hidden(_ publisher: some Publisher<Bool, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.isHidden = value
        }
        .store(in: .current)        
        return self
    }
}
