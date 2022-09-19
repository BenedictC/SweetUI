import Foundation
import Combine


public struct StoredAction<C: CancellablesStorageProvider, Context> {

    typealias Handler = (C, Context) -> Void


    // MARK: Properties

    let cancellablesStorageProvider: C
    let cancellableIdentifier: AnyHashable
    let handler: Handler


    // MARK: Instance life cycle

    init(cancellablesStorageProvider: C, cancellableIdentifier: AnyHashable = UUID().uuidString,  handler: @escaping Handler) {
        self.cancellablesStorageProvider = cancellablesStorageProvider
        self.cancellableIdentifier = cancellableIdentifier
        self.handler = handler
    }
}


// MARK: - Factory

public extension CancellablesStorageProvider {

    func action<Context>(_ handler: @escaping (Self, Context) -> Void) -> StoredAction<Self, Context> {
        StoredAction(cancellablesStorageProvider: self, handler: handler)
    }

    func action<Context>(_ handler: @escaping (Self) -> Void) -> StoredAction<Self, Context> {
        StoredAction(cancellablesStorageProvider: self, handler: { view, _ in handler(view) })
    }

    func action<Context>(_ handler: @escaping () -> Void) -> StoredAction<Self, Context> {
        StoredAction(cancellablesStorageProvider: self, handler: { _, _ in handler() })
    }
}
