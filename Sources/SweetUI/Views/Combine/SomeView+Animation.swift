import UIKit
import Combine


public extension SomeView {

    func animateIsActive<C: CancellablesStorageProvider, P: Publisher>(
        of constraintFactory: (Self) -> NSLayoutConstraint,
        with subscriberFactory: SubscriberFactory<C, P>,
        animatorFactory: @escaping () -> UIViewPropertyAnimator = { UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) })
    -> Self where P.Output == Bool, P.Failure == Never {
        let constraint = constraintFactory(self)
        subscriberFactory.makeSubscriber { root, isActive in
            guard constraint.isActive != isActive else { return }
            constraint.isActive = isActive

            let container = UIView.viewToLayout(for: constraint)
            guard let container = container, container.window != nil else { return }
            let animator = animatorFactory()
            animator.addAnimations { container.layoutIfNeeded() }
            animator.startAnimation()
        }
        return self
    }

    func animateConstant<C: CancellablesStorageProvider, P: Publisher>(
        of constraintFactory: (Self) -> NSLayoutConstraint,
        with subscriberFactory: SubscriberFactory<C, P>,
        animatorFactory: @escaping () -> UIViewPropertyAnimator = { UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) })
    -> Self where P.Output == CGFloat, P.Failure == Never {
        let constraint = constraintFactory(self)
        subscriberFactory.makeSubscriber { _, constant in
            guard constraint.constant != constant else { return }
            constraint.constant = constant

            let container = UIView.viewToLayout(for: constraint)
            guard let container = container, container.window != nil else { return }
            let animator = animatorFactory()
            animator.addAnimations { container.layoutIfNeeded() }
            animator.startAnimation()
        }
        return self
    }
}


// MARK: - Helpers

private extension UIView {

    var ancestors: [UIView] {
        var ancestors = [UIView]()
        var ancestor = superview
        while let next = ancestor {
            ancestors.append(next)
            ancestor = next.superview
        }
        return ancestors
    }

    static func viewToLayout(for constraint: NSLayoutConstraint) -> UIView? {
        let firstView = constraint.firstItem as? UIView
        let secondView = constraint.secondItem as? UIView
        let primary = firstView ?? secondView
        let result = primary?.nearestCommonAncestor(with: secondView)
        return result
    }

    func nearestCommonAncestor(with other: UIView?) -> UIView? {
        guard let other = other else { return superview }
        if self == other { return superview }

        let ancestors = self.ancestors
        let otherAncestors = other.ancestors
        let viewDepth = min(ancestors.count, otherAncestors.count)
        guard viewDepth > 0 else { return nil }
        var lastMatch: UIView?
        for i in 1..<viewDepth {
            let ancestor = ancestors[ancestors.count - i]
            let otherAncestor = otherAncestors[otherAncestors.count - i]
            guard ancestor == otherAncestor else {
                break
            }
            lastMatch = ancestor
        }
        if lastMatch == self {
            return self.superview
        }
        if lastMatch == other {
            return other.superview
        }
        return lastMatch
    }
}
