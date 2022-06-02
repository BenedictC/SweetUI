import Foundation
import UIKit


public class IntrinsicFillAdjustmentContainer<T: UIView>: Container<T>, IntrinsicFillSupporting {

    // MARK: Properties

    let optionalIntrinsicFillAxes: Axis?
    public var intrinsicallyFillsAxes: Axis {
        optionalIntrinsicFillAxes ?? UIView.intrinsicFillAxis(for: content)
    }


    // MARK: Instance life cycle

    init(content: T, intrinsicallyFillsAxes: Axis?) {
        self.optionalIntrinsicFillAxes = intrinsicallyFillsAxes
        super.init(content: content)

        addAndFill(subview: content, overrideEdgesIgnoringSafeArea: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: -

public extension SomeView {

    func intrinsicallyFills(_ axes: Axis) -> IntrinsicFillAdjustmentContainer<Self> {
        return IntrinsicFillAdjustmentContainer(content: self, intrinsicallyFillsAxes: axes)
    }
}
