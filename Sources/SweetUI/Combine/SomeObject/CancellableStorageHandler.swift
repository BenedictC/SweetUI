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


// MARK: - Handling multiple Cancellables

public extension SomeObject {

    func storeCancellables(for key: AnyHashable = UUID(), cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared, @CancellablesBuilder using cancellableBuilder: () -> AnyCancellable) {
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder() }
        let storageKey = CancellableStorageKey(object: self, identifier: key)
        cancellableStorageProvider.storeCancellable(cancellable, forKey: storageKey)
    }

    @discardableResult
    func removeCancellables(for key: AnyHashable, from cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared) -> AnyCancellable? {
        let storageKey = CancellableStorageKey(object: self, identifier: key)
        return cancellableStorageProvider.removeCancellable(forKey: storageKey)
    }
}


@resultBuilder
public struct CancellablesBuilder {

    public static func buildBlock(_ components: (any Cancellable)?...) -> AnyCancellable {
        let cancellables = components.compactMap { $0 }
        return AnyCancellable {
            cancellables.forEach { $0.cancel() }
        }
    }
}


// MARK: - Cancellable

//extension Cancellable {
//
//    @_disfavoredOverload
//    func store(in object: AnyObject, forKey key: AnyHashable = UUID(), using cancellableStorageProvider: CancellableStorageProvider = DefaultCancellableStorageProvider.shared) {
//        let anyCancellable = self as? AnyCancellable ?? AnyCancellable(self)
//        let storageKey = CancellableStorageKey(object: object, identifier: key)
//        cancellableStorageProvider.storeCancellable(anyCancellable, forKey: storageKey)
//    }
//}
