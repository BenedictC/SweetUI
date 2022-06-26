import Foundation
import UIKit


public final class HStack: UIStackView {

    @available(*, unavailable)
    public override var axis: NSLayoutConstraint.Axis {
        get { super.axis }
        set { super.axis = newValue }
    }

    public init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = UIStackView.spacingUseDefault, arrangedSubviews: [UIView] = []) {
        super.init(frame: .zero)
        super.axis = .horizontal

        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing

        arrangedSubviews.forEach { self.addArrangedSubview($0) }
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public extension HStack {

    convenience init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = UIStackView.spacingUseDefault,  @ArrangedSubviewsBuilder arrangedSubviewsBuilder: () -> [UIView]) {
        let arrangedSubviews = arrangedSubviewsBuilder()
        self.init(distribution: distribution, alignment: alignment, spacing: spacing, arrangedSubviews: arrangedSubviews)
    }
}
