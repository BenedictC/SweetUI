import Foundation


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
            debugPrint("Potential retain cycle detected in \(Thread.callStackSymbols[0])")
        }
    }

    return result
}
