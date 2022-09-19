import Combine
import Foundation


public protocol CancellablesStorageProvider: AnyObject {

    var cancellablesStorage: CancellablesStorage { get }
}


// MARK: - Default storage

extension CancellablesStorageProvider {

    private var cancellablesScope: Any.Type { CancellablesStorageProvider.self }

    @discardableResult
    public func storeCancellable<C: Cancellable>(_ cancellable: C, for key: AnyHashable = UUID()) -> AnyHashable {
        let anyCancellable: AnyCancellable
        if let cancellable = cancellable as? AnyCancellable {
            anyCancellable = cancellable
        } else {
            anyCancellable = AnyCancellable(cancellable)
        }
        cancellablesStorage.setCancellable(anyCancellable, forKey: key, inScope: cancellablesScope)
        return key
    }

    public func discardCancellable(for key: AnyHashable) {
        cancellablesStorage.removeCancellable(forKey: key, inScope: cancellablesScope)
    }
}


public extension CancellablesStorageProvider {

    func collectCancellables(for key: AnyHashable = UUID().uuidString, @CancellablesBuilder using cancellableBuilder: () -> AnyCancellable) {
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder() }
        storeCancellable(cancellable, for: key)
    }
}


// MARK: - CancellablesStorage

public final class CancellablesStorage {

    // MARK: Types

    public typealias Scope = Any.Type
    public typealias Key = AnyHashable
    private typealias CancellablesByKey = [Key: AnyCancellable]


    // MARK: Properties

    private var cancellationsByScope = [String: CancellablesByKey]()


    // MARK: Instance life cycle
    
    public init() { }


    // MARK: Cancellables management

    private func scopeKey(for scope: Any.Type) -> String {
        "\(scope)"
    }

    public func hasScope(_ scope: Scope) -> Bool {
        cancellationsByScope[scopeKey(for: scope)] != nil
    }

    public func setCancellable(_ cancellable: AnyCancellable, forKey key: Key, inScope scope: Scope) {
        let scopeKey = scopeKey(for: scope)
        var cancellables = cancellationsByScope[scopeKey] ?? [:]
        cancellables[key] = cancellable
        cancellationsByScope[scopeKey] = cancellables
    }
    
    public func removeCancellable(forKey key: Key, inScope scope: Scope) {
        let scopeKey = scopeKey(for: scope)
        guard var cancellations = cancellationsByScope[scopeKey] else {
            return
        }
        cancellations.removeValue(forKey: key)
        cancellationsByScope[scopeKey] = cancellations
    }

    public func removeAllCancellables(inScope scope: Scope) {
        let scopeKey = scopeKey(for: scope)
        cancellationsByScope.removeValue(forKey: scopeKey)
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
