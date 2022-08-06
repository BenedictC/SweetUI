import UIKit
import Combine


public extension SomeView {

    func animateIsActive<A: ViewIsAvailableProvider, P: Publisher>(
        of constraintFactory: (Self) -> NSLayoutConstraint,
        with publisherParameter: ValueParameter<A, Self, P>,
        animatorFactory: @escaping () -> UIViewPropertyAnimator = { UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) }
    ) -> Self
    where P.Output == Bool, P.Failure == Never {
        publisherParameter.context = self
        publisherParameter.invalidationHandler = { [weak publisherParameter] in
            guard let root = publisherParameter?.root else { return }
            guard let identifier = publisherParameter?.identifier else { return }
            root.removeViewIsAvailableHandler(forIdentifier: identifier)
        }
        let constraint = constraintFactory(self)
        publisherParameter.root?.addViewIsAvailableHandler(withIdentifier: publisherParameter.identifier) {
            guard let publisher = publisherParameter.makeValue() else {
                return  nil
            }
            return publisher.sink { freshValue in
                let staleValue = constraint.isActive
                let isChanged = staleValue != freshValue

                guard isChanged else { return }
                constraint.isActive = freshValue

                let container = UIView.viewToLayout(for: constraint)
                guard let container = container, container.window != nil else { return }
                let animator = animatorFactory()
                animator.addAnimations {
                    container.layoutIfNeeded()
                }
                animator.startAnimation()
            }
        }
        return self
    }

    func animateIsActive<A: ViewIsAvailableProvider, P: Publisher>(
        of constraintFactory: (Self) -> NSLayoutConstraint,
        with publisherParameter: ValueParameter<A, Self, P>,
        animatorFactory: @escaping () -> UIViewPropertyAnimator = { UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) }
    ) -> Self
    where P.Output == CGFloat, P.Failure == Never {
        publisherParameter.context = self
        publisherParameter.invalidationHandler = { [weak publisherParameter] in
            guard let root = publisherParameter?.root else { return }
            guard let identifier = publisherParameter?.identifier else { return }
            root.removeViewIsAvailableHandler(forIdentifier: identifier)
        }
        let constraint = constraintFactory(self)
        publisherParameter.root?.addViewIsAvailableHandler(withIdentifier: publisherParameter.identifier) {
            guard let publisher = publisherParameter.makeValue() else {
                return  nil
            }
            return publisher.sink { freshValue in
                let staleValue = constraint.constant
                let isChanged = staleValue != freshValue

                guard isChanged else { return }
                constraint.constant = freshValue

                let container = UIView.viewToLayout(for: constraint)
                guard let container = container, container.window != nil else { return }
                let animator = animatorFactory()
                animator.addAnimations {
                    container.layoutIfNeeded()
                }
                animator.startAnimation()
            }
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
        var lastMatch: UIView?
        for i in 1...min(ancestors.count, otherAncestors.count) {
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
