import Foundation


func detectPotentialRetainCycle<T>(of object: CFTypeRef, performing work: () -> T) -> T {
    let expectedCount = CFGetRetainCount(object)
    let result = work()
    let actualCount = CFGetRetainCount(object)

    if actualCount != expectedCount {
        let increment = actualCount - expectedCount
        DebugWarning.raise("Potential retain cycle detected. Retain count incremented by \(increment). This may be a false positive caused by the object being temporarily retained by asynchronous functions (e.g. a Task, DispatchQueue or Operation).")
    }

    return result
}
