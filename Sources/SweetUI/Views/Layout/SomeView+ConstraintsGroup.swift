import Foundation
import UIKit


// MARK: - Primary elements

// This is cheeky. The behave is more class like than modifier so we use class naming style.
public func Constrain<T>(in closure: (ConstraintsGroup) -> T) -> T {
    let group = ConstraintsGroup()
    return closure(group)
}


public extension SomeView {

    func store(in group: ConstraintsGroup, as identifier: AnyHashable) -> Self {
        group.setItem(self, forIdentifier: identifier)
        return self
    }

    func constraints(
        for group: ConstraintsGroup,
        activate: Bool = true,
        @ConstraintsBuilder builder: (ConstraintsGroupItemsProvider) -> [NSLayoutConstraint]
    ) -> Self {
        let constraints = builder(group)
        group.setConstraints(constraints)
        group.isConstraintsActive = activate
        return self
    }

    func constraints(
        for group: ConstraintsGroup,
        activate: Bool = true,
        @ConstraintsBuilder builder: (ConstraintsGroupItemsProvider, Self) -> [NSLayoutConstraint]
    ) -> Self {
        let constraints = builder(group, self)
        group.setConstraints(constraints)
        group.isConstraintsActive = activate
        return self
    }
}


// MARK: - ConstraintsGroup

public protocol ConstraintsGroupItemsProvider {

    subscript<T>(item identifier: AnyHashable, ofType type: T.Type) -> T { get }
}


public extension ConstraintsGroupItemsProvider {

    subscript(view identifier: AnyHashable) -> UIView {
        self[item: identifier, ofType: UIView.self]
    }
}


public final class ConstraintsGroup: ConstraintsGroupItemsProvider {

    public var isConstraintsActive: Bool = false {
        didSet {
            if isConstraintsActive {
                NSLayoutConstraint.activate(constraints)
            } else {
                NSLayoutConstraint.deactivate(constraints)
            }
        }
    }

    private var constraints = [NSLayoutConstraint]()
    private var storage = [AnyHashable: Any]()

    public subscript<T>(item identifier: AnyHashable, ofType type: T.Type) -> T {
        guard let item = storage[identifier] else {
            preconditionFailure("Item with identifier '\(identifier)' not found.")
        }
        guard let item = item as? T else {
            preconditionFailure("Item with identifier '\(identifier)' is not of type '\(type)'.")
        }
        return item
    }

    func setItem(_ item: Any, forIdentifier identifier: AnyHashable) {
        storage[identifier] = item
    }

    func setConstraints(_ constraints: [NSLayoutConstraint]) {
        precondition(self.constraints.isEmpty, "Constraints has already been set. Constraints can only be set once.")
        self.constraints = constraints
    }
}


// MARK: - Constraints builder

@resultBuilder
public struct ConstraintsBuilder {

    public static func buildBlock(_ components: NSLayoutConstraint...) -> [NSLayoutConstraint] {
        components
    }
}
