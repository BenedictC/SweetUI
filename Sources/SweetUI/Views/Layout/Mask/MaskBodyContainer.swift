import UIKit


class MaskBodyContainer: UIView {

    // MARK: Properties

    let body: UIView
    let bodyWidthConstraint: NSLayoutConstraint
    let bodyHeightConstraint: NSLayoutConstraint


    // MARK: Instance life cycle

    init(body: UIView) {
        self.body = body
        self.bodyWidthConstraint = body.widthAnchor.constraint(equalToConstant: 0)
        self.bodyWidthConstraint.priority = .almostRequired
        self.bodyHeightConstraint = body.heightAnchor.constraint(equalToConstant: 0)
        self.bodyHeightConstraint.priority = .almostRequired
        super.init(frame: .zero)

        body.translatesAutoresizingMaskIntoConstraints = false
        addSubview(body)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: topAnchor),
            body.bottomAnchor.constraint(equalTo: bottomAnchor),
            body.leftAnchor.constraint(equalTo: leftAnchor),
            body.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Sizing

    func setBodyToIntrinsicSize() -> CGSize {
        deactivateBodySizeConstraints()
        translatesAutoresizingMaskIntoConstraints = false

        // Ensure we're the correct size
        setNeedsLayout()
        layoutIfNeeded()
        // Get bodySize
        let bodySize = bounds.size

        // Apply bodySize to the body
        bodyWidthConstraint.constant = bodySize.width
        bodyHeightConstraint.constant = bodySize.height
        return bodySize
    }

    func deactivateBodySizeConstraints() {
        NSLayoutConstraint.deactivate([
            bodyWidthConstraint,
            bodyHeightConstraint
        ])
    }

    func activateBodySizeConstraints() {
        NSLayoutConstraint.activate([
            bodyWidthConstraint,
            bodyHeightConstraint
        ])
    }
}
