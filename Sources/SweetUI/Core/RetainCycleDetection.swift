import Foundation


func detectPotentialRetainCycle<T>(of object: CFTypeRef, performing work: () -> T) -> T {
    let expectedCount = CFGetRetainCount(object)
    let result = work()
    let actualCount = CFGetRetainCount(object)

    if actualCount != expectedCount {
        DebugWarning.raise("Potential retain cycle detected in \(Thread.callStackSymbols[0])")
    }

    return result
}
