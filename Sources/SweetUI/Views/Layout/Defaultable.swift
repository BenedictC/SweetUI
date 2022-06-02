public protocol Defaultable {
    init()
    static var `default`: Self { get }
}

public extension Defaultable {
    static var `default`: Self { Self.init() }
}
