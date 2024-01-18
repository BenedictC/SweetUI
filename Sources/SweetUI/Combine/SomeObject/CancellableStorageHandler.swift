import Foundation
import Combine


// MARK: -

public typealias CancellableStorageHandler = (_ cancellable: AnyCancellable, _ forObject: AnyObject) -> Void


public extension DefaultCancellableStorage {

    static let shared = DefaultCancellableStorage()

    func store(_ cancellable: AnyCancellable, for object: AnyObject) {
        let key = UUID()
        self.store(cancellable, for: object, key: key)
    }
}


// MARK: - Default

// TODO: Should we enforce @MainActor?
public class DefaultCancellableStorage {

    private class StoredCancellables: SomeObject {
        private var keyed = [AnyHashable: AnyCancellable]()

        func store(_ cancellable: AnyCancellable, for key: AnyHashable) {
            keyed[key] = cancellable
        }

        func removeCancellable(for key: AnyHashable) {
            keyed.removeValue(forKey: key)
        }
    }

    private let cancellablesByObject = NSMapTable<AnyObject, StoredCancellables>.weakToStrongObjects()


    public func store(_ cancellable: AnyCancellable, for object: AnyObject, key: AnyHashable) {
        let cancellables: StoredCancellables
        if let existing = cancellablesByObject.object(forKey: object) {
            cancellables = existing
        } else {
            cancellables = StoredCancellables()
            cancellablesByObject.setObject(cancellables, forKey: object)
        }
        cancellables.store(cancellable, for: key)
    }

    func removeCancellable(for object: AnyObject, key: AnyHashable) {
        guard let cancellables = cancellablesByObject.object(forKey: object) else { return }
        cancellables.removeCancellable(for: key)
    }
}



public extension SomeObject {

    func collectCancellables(for key: AnyHashable = UUID(), @CancellablesBuilder using cancellableBuilder: () -> AnyCancellable) {
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder() }
        DefaultCancellableStorage.shared.store(cancellable, for: self, key: key)
    }
}


// MARK: - CancellablesBuilder

@resultBuilder
public struct CancellablesBuilder {

    public static func buildBlock(_ components: (any Cancellable)?...) -> AnyCancellable {
        let cancellables = components.compactMap { $0 }
        return AnyCancellable {
            cancellables.forEach { $0.cancel() }
        }
    }
}
