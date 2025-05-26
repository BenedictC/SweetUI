import UIKit


public final class Button<Body: UIView>: Control {

    // MARK: Types

    public typealias HitTestHandler = (_ body: Body, _ point: CGPoint, _ event: UIEvent?) -> UIView?


    // MARK: Properties

    public private(set) var body: Body
    public var hitTestHandler: HitTestHandler


    // MARK: Instance life cycle

    public init(body bodyFactory: (AnyPublisher<UIControl.State, Never>) -> Body) {
        var stateChanges = Published(wrappedValue: UIControl.State.normal)
        let cancellables = CancellableStorage()
        CancellableStorage.push(cancellables)
        self.body = bodyFactory(stateChanges.projectedValue.eraseToAnyPublisher())
        CancellableStorage.pop(expected: cancellables)
        self.hitTestHandler = Self.makeDefaultHitTestProvider()
        super.init(stateChanges: stateChanges)
        self.cancellableStorage.adoptCancellables(from: cancellables)
        self.accessibilityTraits = [.button]
    }


    // MARK: Hit Testing

    public static func makeDefaultHitTestProvider() -> HitTestHandler {
        return { body, point, event in
            guard let subview = body.hitTest(point, with: event) else {
                return nil
            }
            let isControl = subview is UIControl
            let hasEnabledRecognizers = subview.gestureRecognizers?.contains { $0.isEnabled } ?? false
            let shouldUseSubview = isControl || hasEnabledRecognizers
            return shouldUseSubview ? subview : nil
        }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let bodyPoint = convert(point, to: body)
        if let subview = hitTestHandler(body, bodyPoint, event) {
            return subview
        }
        let isInBounds = bounds.contains(point)
        return isInBounds ? self : nil
    }
}
