import Foundation


// MARK: - CancellableStorageProvider

@MainActor
public protocol CancellableStorageProvider {
    
    var cancellableStorage: CancellableStorage { get }
}


// MARK: - CancellableStorage

@MainActor
public final class CancellableStorage {
    
    private static var storageStack: [CancellableStorage] = [CancellableStorage(isFallback: true)]
    
    private let isFallback: Bool
    private var cancellablesByKey = [CancellableStorageKey: AnyCancellable]()
    private var unionCancellable: AnyCancellable {
        let children = cancellablesByKey.values
        return AnyCancellable {
            for child in children { child.cancel() }
        }
    }
    
    public init() {
        self.isFallback = false
    }
    
    private init(isFallback: Bool) {
        self.isFallback = isFallback
    }
    
    public func storeCancellable(_ cancellable: AnyCancellable, withKey key: CancellableStorageKey = .unique()) {
        if isFallback {
            runtimeWarn("Attempt to store cancellable with key '\(key.identifier)' while outside of a CancellableStorage scope. Cancellable will be stored but cannot be released.")
            cancellablesByKey[.unique()] = cancellable
        } else {
            cancellablesByKey[key] = cancellable
        }
    }
    
    public func removeCancellable(forKey key: CancellableStorageKey) -> AnyCancellable? {
        cancellablesByKey.removeValue(forKey: key)
    }
}


// MARK: - CancellableStorageKey

public struct CancellableStorageKey: Equatable, Hashable {
    
    public let identifier: AnyHashable
    
    public init(identifier: AnyHashable) {
        self.identifier = identifier
    }
}


// MARK: - CancellableStorageKey factories

public extension CancellableStorageKey {
    
    private static var propertyUUIDsByKeyPath = [AnyHashable: UUID]()
    
    static func property<R: AnyObject, P>(_ keyPath: KeyPath<R, P>, of object: R) -> Self {
        let uuid: UUID
        if let existing = propertyUUIDsByKeyPath[keyPath] {
            uuid = existing
        } else {
            uuid = UUID()
            propertyUUIDsByKeyPath[keyPath] = uuid
        }
        return .named(uuid.uuidString, for: object)
    }
    
    static func named(_ name: String, for object: AnyObject? = nil) -> Self {
        let pointer = object.flatMap { "\(Unmanaged.passUnretained($0).toOpaque())" } ?? ""
        let identifier = "\(pointer):\(name)"
        return CancellableStorageKey(identifier: identifier)
    }
    
    static func unique() -> Self {
        return CancellableStorageKey(identifier: UUID())
    }
}


// MARK: - Cancellable collection

public extension CancellableStorage {
    
    @MainActor
    static var current: CancellableStorage {
        guard let top = storageStack.last else {
            preconditionFailure("providersStack should contain at least 1 element.")
        }
        return top
    }
}


// MARK: - Collection that returns a Cancellable

public extension CancellableStorage {
    
    @discardableResult
    static func collectCancellables<T>(in cancellable: inout AnyCancellable?, action: () -> T) -> T {
        let storage = CancellableStorage()
        Self.storageStack.append(storage)
        let result = action()
        let last = Self.storageStack.removeLast()
        assert(last === storage)
        
        cancellable = storage.unionCancellable
        return result
    }
    
    @discardableResult
    static func collectCancellables(action: () -> Void) -> AnyCancellable {
        var cancellable: AnyCancellable?
        collectCancellables(in: &cancellable, action: action)
        guard let cancellable else {
            return AnyCancellable { } // Shouldn't happen!
        }
        return cancellable
    }
}


// MARK: - Collection that stores in storage

public extension CancellableStorage {
    
    @discardableResult
    func collectCancellables<T>(with key: CancellableStorageKey = .unique(), actions: () -> T) -> T {
        var cancellable: AnyCancellable?
        let result = Self.collectCancellables(in: &cancellable, action: actions)
        if let cancellable {
            storeCancellable(cancellable, withKey: key)
        } else {
            // Shouldn't happen!
        }
        return result
    }
}


// MARK: - CancellableStorageProvider convenience

public extension CancellableStorageProvider {
    
    func collectCancellables<T>(with key: CancellableStorageKey = .unique(), actions: () -> T) -> T {
        cancellableStorage.collectCancellables(with: key, actions: actions)
    }
}


// MARK: - Cancellable convenience

public extension Cancellable {
    
    @MainActor
    func store(in provider: CancellableStorageProvider, withKey key: CancellableStorageKey = .unique()) {
        store(in: provider.cancellableStorage, withKey: key)
    }
    
    @MainActor
    func store(in storage: CancellableStorage, withKey key: CancellableStorageKey = .unique()) {
        let anyCancellable = self as? AnyCancellable ?? AnyCancellable(self)
        storage.storeCancellable(anyCancellable, withKey: key)
    }
}
