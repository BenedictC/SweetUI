import Foundation
import Combine


// MARK: - CancellableStorageProvider

public protocol CancellableStorageProvider {

    func storeCancellable(_ cancellable: AnyCancellable, forKey key: CancellableStorageKey)
    func removeCancellable(forKey key: CancellableStorageKey) -> AnyCancellable?
}


public struct CancellableStorageKey: Equatable {

    public let object: AnyObject
    public let identifier: AnyHashable

    public init(object: AnyObject, identifier: AnyHashable) {
        self.object = object
        self.identifier = identifier
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.object === rhs.object && lhs.identifier == rhs.identifier
    }

    public static func unique(for object: AnyObject, fileID: StaticString = #fileID, line: UInt = #line, column: UInt = #column) -> Self {
        let identifier = "\(fileID):\(line):\(column)"
        return CancellableStorageKey(object: object, identifier: identifier)
    }
}


// MARK: - DefaultCancellableStorageProvider

public class DefaultCancellableStorageProvider: CancellableStorageProvider {
    
    // MARK: Types

    private class StoredCancellables: SomeObject {
        private var cancellablesByIdentifier = [AnyHashable: AnyCancellable]()

        func store(_ cancellable: AnyCancellable, for identifier: AnyHashable) {
            cancellablesByIdentifier[identifier] = cancellable
        }

        func removeCancellable(for identifier: AnyHashable) -> AnyCancellable? {
            cancellablesByIdentifier.removeValue(forKey: identifier)
        }
    }


    // MARK: Properties

    public static let shared = DefaultCancellableStorageProvider()

    private let cancellablesByObject = NSMapTable<AnyObject, StoredCancellables>.weakToStrongObjects()


    // MARK: CancellableStorageProvider

    public func storeCancellable(_ cancellable: AnyCancellable, forKey key: CancellableStorageKey) {
        let cancellables: StoredCancellables
        if let existing = cancellablesByObject.object(forKey: key.object) {
            cancellables = existing
        } else {
            cancellables = StoredCancellables()
            cancellablesByObject.setObject(cancellables, forKey: key.object)
        }
        cancellables.store(cancellable, for: key.identifier)
    }

    @discardableResult
    public func removeCancellable(forKey key: CancellableStorageKey) -> AnyCancellable? {
        guard let cancellables = cancellablesByObject.object(forKey: key.object) else { return nil }
        return cancellables.removeCancellable(for: key.identifier)
    }
}


// MARK: - SomeObject additions

public extension SomeObject {

    func storeCancellable(_ cancellable: Cancellable, forKey key: AnyHashable = UUID(), cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared) {
        let storageKey = CancellableStorageKey(object: self, identifier: key)
        let anyCancellable = (cancellable as? AnyCancellable) ?? AnyCancellable(cancellable)
        cancellableStorageProvider.storeCancellable(anyCancellable, forKey: storageKey)
    }

    @discardableResult
    func removeCancellable(forKey key: AnyHashable, from cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared) -> AnyCancellable? {
        let storageKey = CancellableStorageKey(object: self, identifier: key)
        return cancellableStorageProvider.removeCancellable(forKey: storageKey)
    }
}


// MARK: - Cancellable additions

public extension Cancellable {

    func store(with object: SomeObject, forKey key: AnyHashable = UUID(), cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared) {
        object.storeCancellable(self, forKey: key, cancellableStorageProvider: cancellableStorageProvider)
    }
}


public extension AnyCancellable {

    static func collect(@ArrayBuilder<Cancellable> builder: () -> [Cancellable]) -> Cancellable{
        let cancellables = builder()
        return AnyCancellable {
            for cancellable in cancellables {
                cancellable.cancel()
            }
        }
    }
}
