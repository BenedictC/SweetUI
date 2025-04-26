import UIKit


class MaskSizedByContent: UIView {

    // MARK: Properties

    let maskAlignment: ContentAlignment
    let content: UIView
    let maskBody: UIView

    private let maskBodyContainer: MaskBodyContainer


    // MARK: Instance life cycle

    init(maskAlignment: ContentAlignment, content: UIView, mask: UIView) {
        self.maskAlignment = maskAlignment
        self.content = content
        self.maskBody = mask
        self.maskBodyContainer = MaskBodyContainer(body: mask)

        super.init(frame: .zero)

        addContentIfNeeded(size: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Layout

    func addContentIfNeeded(size: CGSize?) {
        guard content.superview == nil else {
            return
        }
        addSubview(content)

        let edgeConstraints = [
            content.topAnchor.constraint(equalTo: topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor),
            content.leftAnchor.constraint(equalTo: leftAnchor),
            content.rightAnchor.constraint(equalTo: rightAnchor),
        ]
        let sizeConstraints = size.map { size in
            [
                content.widthAnchor.constraint(equalToConstant: size.width),
                content.heightAnchor.constraint(equalToConstant: size.height),
            ]
        } ?? []
        NSLayoutConstraint.activate(edgeConstraints + sizeConstraints)
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()

        _ = maskBodyContainer.setBodyToIntrinsicSize()
        let contentSize = content.bounds.size

        let maskSize: CGSize
        switch maskAlignment {
        case .fill:
            maskSize = contentSize
            maskBodyContainer.bodyWidthConstraint.constant = maskSize.width
            maskBodyContainer.bodyHeightConstraint.constant = maskSize.height
            maskBodyContainer.activateBodySizeConstraints()

        case .topLeft, .top, .topRight,
                .left, .center, .right,
                .bottomLeft, .bottom, .bottomRight,
                .topLeading, .topTrailing,
                .leading, .trailing,
                .bottomLeading, .bottomTrailing:
            maskBodyContainer.layoutSubviews()
            let size = maskBodyContainer.bounds.size
            let isEmpty = size.width == 0 || size.height == 0
            if isEmpty {
                log.info("Mask has zero size. Content will not be visible.")
            }
            maskSize = size
        }


        let x: CGFloat
        switch maskAlignment {
        case .fill:
            x = 0
        case .topLeft, .left, .bottomLeft:
            x = 0
        case .top, .center, .bottom:
            x = (contentSize.width - maskSize.width) / 2
        case .topRight, .right, .bottomRight:
            x = contentSize.width - maskSize.width

        case .topLeading, .leading, .bottomLeading:
            switch effectiveUserInterfaceLayoutDirection {
            case .leftToRight:
                x = 0
            case .rightToLeft:
                x = contentSize.width - maskSize.width
            @unknown default:
                x = 0
            }

        case .topTrailing, .trailing, .bottomTrailing:
            switch effectiveUserInterfaceLayoutDirection {
            case .leftToRight:
                x = contentSize.width - maskSize.width
            case .rightToLeft:
                x = 0
            @unknown default:
                x = contentSize.width - maskSize.width
            }
        }
        let y: CGFloat
        switch maskAlignment {
        case .fill:
            y = 0
        case .topLeft, .top, .topRight, .topLeading, .topTrailing:
            y = 0
        case .left, .center, .right, .leading, .trailing:
            y = (contentSize.height - maskSize.height) / 2
        case .bottomLeft, .bottom, .bottomRight, .bottomLeading, .bottomTrailing:
            y = contentSize.height - maskSize.height
        }
        maskBodyContainer.frame = CGRect(x: x, y: y, width: maskSize.width, height: maskSize.height)
        content.mask = maskBodyContainer
    }
}
