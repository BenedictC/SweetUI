import Foundation
import Combine


// MARK: -

public typealias CancellableStorageHandler = (_ cancellable: AnyCancellable, _ forObject: NSObject) -> Void


public extension DefaultCancellableStorage {

    static let shared = DefaultCancellableStorage()

    func store(_ cancellable: AnyCancellable, for object: NSObject) {
        let key = UUID()
        self.store(cancellable, for: object, key: key)
    }
}


// MARK: - Default

// TODO: Should we enforce @MainActor?
public class DefaultCancellableStorage {

    private class StoredCancellables: NSObject {
        private var keyed = [AnyHashable: AnyCancellable]()

        func store(_ cancellable: AnyCancellable, for key: AnyHashable) {
            keyed[key] = cancellable
        }

        func removeCancellable(for key: AnyHashable) {
            keyed.removeValue(forKey: key)
        }
    }

    private let cancellablesByObject = NSMapTable<NSObject, StoredCancellables>.weakToStrongObjects()


    public func store(_ cancellable: AnyCancellable, for object: NSObject, key: AnyHashable) {
        let cancellables: StoredCancellables
        if let existing = cancellablesByObject.object(forKey: object) {
            cancellables = existing
        } else {
            cancellables = StoredCancellables()
            cancellablesByObject.setObject(cancellables, forKey: object)
        }
        cancellables.store(cancellable, for: key)
    }

    func removeCancellable(for object: NSObject, key: AnyHashable) {
        guard let cancellables = cancellablesByObject.object(forKey: object) else { return }
        cancellables.removeCancellable(for: key)
    }
}



public extension NSObject {

    func collectCancellables(for key: AnyHashable = UUID(), @CancellablesBuilder using cancellableBuilder: () -> AnyCancellable) {
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder() }
        DefaultCancellableStorage.shared.store(cancellable, for: self)
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
