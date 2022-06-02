import Foundation
import Combine


public extension _ViewController {

    func collectCancellables(for key: AnyHashable = UUID().uuidString, @CancellablesBuilder using cancellableBuilder: () -> AnyCancellable) {
        let cancellable = detectPotentialRetainCycle(of: self) { cancellableBuilder() }
        storeCancellable(cancellable, for: key)
    }
}


// MARK: - Retain cycle detection

enum PotentialRetainCycleError: Error {
    case detected
}

func detectPotentialRetainCycle<T>(of object: CFTypeRef, performing work: () -> T) -> T {
    let expectedCount = CFGetRetainCount(object)
    let result = work()
    let actualCount = CFGetRetainCount(object)

    if actualCount != expectedCount {
        do {
            throw PotentialRetainCycleError.detected
        } catch {
            // We only throw for debugging purposes
        }
    }

    return result
}
