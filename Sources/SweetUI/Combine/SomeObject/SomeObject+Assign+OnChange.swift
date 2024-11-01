import Foundation
import Combine


// MARK: - Bind

/// Take a keyPath and return Self
@MainActor
public extension SomeObject {
    
    @discardableResult
    func assign<P: Publisher>(
        to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output>,
        from publisher: P
    ) -> Self where P.Failure == Never {
        publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        .store(in: .current)
        return self
    }
    
    
    // MARK: Promote non-optional publisher to optional
    
    @discardableResult
    func assign<P: Publisher>(
        to destinationKeyPath: ReferenceWritableKeyPath<Self, P.Output?>,
        from publisher: P
    ) -> Self where P.Failure == Never {
        publisher.sink { [weak self] value in
            self?[keyPath: destinationKeyPath] = value
        }
        .store(in: .current)
        return self
    }
}


// MARK: - OnChange

/// Take a closure and return Self
@MainActor
public extension SomeObject {
    
    @discardableResult
    func onChange<V, P: Publisher>(
        of publisher: P,
        perform action: @escaping (Self, P.Output) -> Void
    ) -> Self where P.Output == V, P.Failure == Never {
        // We don't need to store action because it's captured in a block is stored
        publisher.sink { [weak self] newValue in
            guard let self else { return }
            action(self, newValue)
        }
        .store(in: .current)
        return self
    }
}
