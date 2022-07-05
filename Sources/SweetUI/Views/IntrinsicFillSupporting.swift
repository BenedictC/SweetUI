import UIKit


public protocol IntrinsicFillSupporting: UIView {
    var intrinsicallyFillsAxes: Axis { get }
}


// MARK: - Internal UIView additions

extension UIView {

    static func intrinsicFillAxis(for view: UIView) -> Axis {
        if let view = view as? IntrinsicFillSupporting {
            return view.intrinsicallyFillsAxes
        }
        if view is UIScrollView {
            // TODO: This should check for constraints that constrain the frame
            return .both
        }
        return .none
    }

    static func intrinsicallyFills(axis: Axis, view: UIView) -> Bool {
        let fills = intrinsicFillAxis(for: view)
        return fills.contains(axis)
    }
}
