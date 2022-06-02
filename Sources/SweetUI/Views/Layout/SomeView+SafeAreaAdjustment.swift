import Foundation
import UIKit


public class SafeAreaAdjustmentContainer<Content: UIView>: Container<Content>, EdgesIgnoringSafeAreaSupporting {

    // MARK: Properties

    public let safeAreaIgnoringRegions: SafeAreaRegions
    let optionalEdgesIgnoringSafeArea: UIRectEdge?
    public var edgesIgnoringSafeArea: UIRectEdge {
        optionalEdgesIgnoringSafeArea ?? UIView.edgesIgnoringSafeArea(for: content)
    }

    var keyboardNotificationObservation: Any?
    var latestKeyboardFrame: CGRect?
    var additionalSafeAreaInsets = UIEdgeInsets.zero

    override public var safeAreaInsets: UIEdgeInsets {
        var result = super.safeAreaInsets
        result.top += additionalSafeAreaInsets.top
        result.left += additionalSafeAreaInsets.left
        result.bottom += additionalSafeAreaInsets.bottom
        result.right += additionalSafeAreaInsets.right
        return result
    }

    var isOuterMostKeyboardContainer: Bool {
        var ancestor = superview
        while let possibleContainer = ancestor {
            let containerAvoidsKeyboard = (possibleContainer as? EdgesIgnoringSafeAreaSupporting)
                .flatMap({ $0.safeAreaIgnoringRegions.contains(.keyboard) }) ?? false
            if containerAvoidsKeyboard {
                return false
            }
            ancestor = possibleContainer.superview
        }
        return true
    }


    // MARK: Instance life cycle

    init(content: Content, safeAreaIgnoringRegions regions: SafeAreaRegions, edgesIgnoringSafeArea: UIRectEdge?) {
        self.safeAreaIgnoringRegions = regions
        self.optionalEdgesIgnoringSafeArea = edgesIgnoringSafeArea
        super.init(content: content)

        let edgesIgnoringSafeArea = regions.contains(.container)
        ? UIView.edgesIgnoringSafeArea(for: content) // only respect safe edges for containers
        : .all // if it's not a .container then ignore all safe areas
        addAndFill(subview: content, overrideEdgesIgnoringSafeArea: edgesIgnoringSafeArea)

        let notificationCenter = NotificationCenter.default
        let notificationName = UIApplication.keyboardWillChangeFrameNotification
        self.keyboardNotificationObservation = notificationCenter.addObserver(forName: notificationName, object: nil, queue: nil) { [weak self] notification in
            let keyboardFrameValue = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? NSValue
            let keyboardFrame = keyboardFrameValue?.cgRectValue ?? .zero
            self?.latestKeyboardFrame = keyboardFrame

            let animationCurveValue = notification.userInfo?[UIApplication.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurve = animationCurveValue.flatMap { UIView.AnimationCurve(rawValue: $0.intValue) } ?? .linear

            let animationDurationValue = notification.userInfo?[UIApplication.keyboardAnimationDurationUserInfoKey] as? NSNumber
            let animationDuration = animationDurationValue?.doubleValue ?? 0.35
            self?.updateSafeAreaInsets(animationCurve: animationCurve, animationDuration: animationDuration)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Safe area insets

    func updateSafeAreaInsets(animationCurve: UIView.AnimationCurve, animationDuration: TimeInterval) {
        guard let keyboardFrame = latestKeyboardFrame else {
            return
        }
        guard isOuterMostKeyboardContainer else {
            return
        }
        let contentFrame = content.convert(content.bounds, to: nil)
        let intersection = keyboardFrame.intersection(contentFrame)
        let keyboardEncroachment = intersection.height

        // Prevent a weird animation
        let oldValue = self.additionalSafeAreaInsets
        var newValue = oldValue
        newValue.bottom = keyboardEncroachment
        let noChange = newValue == oldValue
        if noChange {
            return
        }
        self.additionalSafeAreaInsets = newValue
        self.setNeedsLayout()
        if animationDuration > 0 {
            UIViewPropertyAnimator(duration: animationDuration, curve: animationCurve) {
                self.layoutIfNeeded()
            }.startAnimation()
        }
    }
}


// MARK: - Modifiers

public extension SomeView {

    func ignoresSafeArea(_ regions: SafeAreaRegions = .container, edges: UIRectEdge) -> SafeAreaAdjustmentContainer<Self> {
        return SafeAreaAdjustmentContainer(content: self, safeAreaIgnoringRegions: regions, edgesIgnoringSafeArea: edges)
    }
}


public extension SomeView {

    func avoidKeyboard() -> SafeAreaAdjustmentContainer<Self> {
        return ignoresSafeArea(.keyboard, edges: [])
    }
}
