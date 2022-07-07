struct DebugWarning: Error, CustomDebugStringConvertible {

    let message: String
    var debugDescription: String { message }

    static func raise(_ message: String) {
        do {
            // We throw so the 'Swift Error' breakpoint kicks in and prevents the warning from being lost in the console
            throw DebugWarning(message: message)
        } catch {
            print("⚠️ Debug warning: \(error)")
        }
    }
}
