import Foundation
import Combine


// MARK: - ViewAvailabilityProvider factory

public extension NSObjectProtocol where Self: ViewAvailabilityProvider {

    func action<Context, Value>(_ closure: @escaping () -> Void) -> ActionParameter<Self, Context, Value> {
        ActionParameter(root: self, action: { _ in closure() })
    }
    func action<Context, Value>(_ closure: @escaping (Self) -> Void) -> ActionParameter<Self, Context, Value> {
        ActionParameter(root: self, action: { closure($0.root) })
    }
    func action<Context, Value>(_ closure: @escaping (Self, Context) -> Void) -> ActionParameter<Self, Context, Value> {
        ActionParameter(root: self, action: { closure($0.root, $0.context) })
    }
    func action<Context, Value>(_ closure: @escaping (Self, Context, Value) -> Void) -> ActionParameter<Self, Context, Value> {
        ActionParameter(root: self, action: { closure($0.root, $0.context, $0.value) })
    }
}


// MARK: - ActionParameter

public final class ActionParameter<Root: AnyObject, Context: AnyObject, Value> {

    // MARK: Types

    public struct Arguments {
        public let root: Root
        public let context: Context
        public let value: Value
    }
    public typealias Action = (Arguments) -> Void


    // MARK: Properties

    internal let identifier = UUID()
    public private(set) weak var root: Root?
    internal weak var context: Context?
    private var action: Action?
    internal var invalidationHandler: (() -> Void)?


    // MARK: Instance life cycle

    init(root: Root, action: @escaping Action) {
        self.root = root
        self.action = action
    }


    // MARK: Execution

    @discardableResult
    func execute(with value: Value) -> Bool {
        guard let root = root,
              let context = context
        else {
            return false
        }
        let arguments = Arguments(root: root, context: context, value: value)
        action?(arguments)
        return true
    }

    public func invalidate() {
        invalidationHandler?()
        invalidationHandler = nil
    }
}
