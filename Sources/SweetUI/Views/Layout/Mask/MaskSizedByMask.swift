import UIKit


class MaskSizedByMask: UIView {

    // MARK: Properties

    let contentAlignment: ContentAlignment
    let content: UIView
    let maskBody: UIView
    let maskBodyContainer: MaskBodyContainer
    let contentContainer = UIView()
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var contentConstraints = [NSLayoutConstraint]()


    // MARK: Instance life cycle

    init(contentAlignment: ContentAlignment, content: UIView, mask: UIView) {
        self.contentAlignment = contentAlignment
        self.content = content
        self.maskBody = mask
        self.maskBodyContainer = MaskBodyContainer(body: mask)
        super.init(frame: .zero)
        self.widthConstraint = widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint.priority = .almostRequired
        self.heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        self.heightConstraint.priority = .almostRequired

        // Content must be added otherwise layoutSubviews is optimised away by UIKit
        content.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(content)
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)
        NSLayoutConstraint.activate([
            contentContainer.leftAnchor.constraint(equalTo: leftAnchor),
            contentContainer.rightAnchor.constraint(equalTo: rightAnchor),
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        if #available(iOS 17.0, *) {
            let sizeTraits: [UITrait] = [UITraitVerticalSizeClass.self, UITraitHorizontalSizeClass.self]
            registerForTraitChanges(sizeTraits, action: #selector(setNeedsLayout))
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Layout

    @available(*, deprecated)
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 17.0, *) {
            // In iOS 17 and later we rely on the trait changes
        } else {
            setNeedsLayout()
        }
    }

    override func layoutSubviews() {
//         Remove the content from the view so it doesn't interfere with mask measuring
        content.removeFromSuperview()
        NSLayoutConstraint.deactivate(contentConstraints)
        widthConstraint.isActive = false
        heightConstraint.isActive = false

        // Add the mask in place of the content
        content.mask = nil
        maskBodyContainer.deactivateBodySizeConstraints()
        addSubview(maskBodyContainer)
        NSLayoutConstraint.activate([
            maskBodyContainer.leftAnchor.constraint(equalTo: leftAnchor),
            maskBodyContainer.rightAnchor.constraint(equalTo: rightAnchor),
            maskBodyContainer.topAnchor.constraint(equalTo: topAnchor),
            maskBodyContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        maskBodyContainer.translatesAutoresizingMaskIntoConstraints = false
        super.layoutSubviews()
        maskBodyContainer.setNeedsLayout()
        maskBodyContainer.layoutIfNeeded()

        // Re-configure the mask
        let maskSize = maskBodyContainer.setBodyToIntrinsicSize()
        // Make container positionable as a mask
        maskBodyContainer.removeFromSuperview()
        maskBodyContainer.translatesAutoresizingMaskIntoConstraints = true
        maskBodyContainer.bodyWidthConstraint.constant = maskSize.width
        maskBodyContainer.bodyHeightConstraint.constant = maskSize.height
        maskBodyContainer.activateBodySizeConstraints()

        // Configure the content
        widthConstraint.constant = maskSize.width
        heightConstraint.constant = maskSize.height
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        addContentIfNeeded(maskSize: maskSize)
        content.mask = maskBodyContainer

        contentContainer.setNeedsLayout()
        contentContainer.layoutIfNeeded()
        let arf = convert(content.frame.origin, from: content)
        var x = -arf.x
        var y = -arf.y
        x = -content.frame.origin.x
        y = -content.frame.origin.y
        maskBodyContainer.frame = CGRect(origin: CGPoint(x: x, y: y), size: maskSize)
    }

    func addContentIfNeeded(maskSize: CGSize) {
        contentContainer.addSubview(content)
        let contentConstraints = switch contentAlignment {
        case .fill:
            [
                content.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
                content.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
                content.widthAnchor.constraint(equalToConstant: maskSize.width).priority(.almostRequired),
                content.heightAnchor.constraint(equalToConstant: maskSize.height).priority(.almostRequired),
            ]

        case .topLeft:
            [
                content.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                content.leftAnchor.constraint(equalTo: contentContainer.leftAnchor),
            ]

        case .top:
            [
                content.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                content.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            ]

        case .topRight:
            [
                content.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                content.rightAnchor.constraint(equalTo: contentContainer.rightAnchor),
            ]

        case .left:
            [
                content.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
                content.leftAnchor.constraint(equalTo: contentContainer.leftAnchor),
            ]

        case .center:
            [
                content.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
                content.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            ]

        case .right:
            [
                content.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
                content.rightAnchor.constraint(equalTo: contentContainer.rightAnchor),
            ]

        case .bottomLeft:
            [
                content.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
                content.leftAnchor.constraint(equalTo: contentContainer.leftAnchor),
            ]

        case .bottom:
            [
                content.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
                content.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
            ]

        case .bottomRight:
            [
                content.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
                content.rightAnchor.constraint(equalTo: contentContainer.rightAnchor),
            ]

        case .topLeading:
            [
                content.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                content.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            ]

        case .leading:
            [
                content.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
                content.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            ]

        case .bottomLeading:
            [
                content.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
                content.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            ]

        case .topTrailing:
            [
                content.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                content.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            ]

        case .trailing:
            [
                content.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
                content.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            ]

        case .bottomTrailing:
            [
                content.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
                content.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            ]
        }
        NSLayoutConstraint.deactivate(self.contentConstraints)
        self.contentConstraints = contentConstraints
        NSLayoutConstraint.activate(contentConstraints)
    }
}
