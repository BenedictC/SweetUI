import Foundation


public extension UIControl {

    func disabled(_ value: Bool) -> Self {
        self.enabled(!value)
    }

    func disabled<P: Publisher>(
        _ publisher: P,
        cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared
    ) -> Self where P.Output == Bool, P.Failure == Never {

        enabled(publisher.inverted, cancellableStorageProvider: cancellableStorageProvider)
    }
}
