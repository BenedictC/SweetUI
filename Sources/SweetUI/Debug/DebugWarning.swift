struct DebugWarning: Error, CustomDebugStringConvertible {

    let message: String
    var debugDescription: String { message }

    static func raise(_ message: String, shouldThrow: Bool = false) {
        if shouldThrow {
            do {
                throw DebugWarning(message: message)
            } catch {
                // We throw so the 'Swift Error' breakpoint kicks in and prevents the warning from being lost in the console
            }
        }
        print("⚠️ Debug warning: \(message)")
    }
}
