import UIKit


// MARK: - Spacer

public class Spacer: UIView {

    public init() {
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Factories

public extension Spacer {

    convenience init(minWidth: CGFloat? = nil,
         idealWidth: CGFloat? = nil,
         idealWidthPriority: UILayoutPriority = .defaultHigh,
         maxWidth: CGFloat? = nil,
         minHeight: CGFloat? = nil,
         idealHeight: CGFloat? = nil,
         idealHeightPriority: UILayoutPriority = .defaultHigh,
         maxHeight: CGFloat? = nil)
    {
        self.init()
        _ = self.frame(minWidth: minWidth, idealWidth: idealWidth, idealWidthPriority: idealWidthPriority, maxWidth: maxWidth, minHeight: minHeight, idealHeight: idealHeight, idealHeightPriority: idealHeightPriority, maxHeight: maxHeight)
    }

    convenience init(width: CGFloat, height: CGFloat? = nil) {
        self.init()
        _ = self.frame(width: width, height: height)
    }

    convenience init(height: CGFloat) {
        self.init()
        _ = self.frame(height: height)
    }
}
