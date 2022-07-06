import Foundation
import Combine


// MARK: - Cancellables

public extension CollectCancellablesProvider {

    func collectCancellables(for key: AnyHashable = UUID().uuidString, @CancellablesBuilder using cancellableBuilder: () -> AnyCancellable) {
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder() }
        storeCancellable(cancellable, for: key)
    }
}
