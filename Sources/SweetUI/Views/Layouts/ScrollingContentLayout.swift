import UIKit


public final class ScrollingContentLayout<Content: UIView>: LayoutView {

    // MARK: Types

    public typealias Content = Content

    public struct Configuration: Defaultable {
        var edgePadding: CGFloat = 20
        var backgroundColor: UIColor? = nil
        var paddingColor: UIColor? = nil
        var avoidsKeyboard: Bool = true
        var alignment: ZStack.Alignment = .center

        public init(edgePadding: CGFloat = 20,
             backgroundColor: UIColor? = nil,
             paddingColor: UIColor? = nil,
             avoidsKeyboard: Bool = true,
             alignment: ZStack.Alignment)
        {
            self.edgePadding = edgePadding
            self.backgroundColor = backgroundColor
            self.paddingColor = paddingColor
            self.avoidsKeyboard = avoidsKeyboard
            self.alignment = alignment
        }

        public init() {
            self.init(alignment: .center)
        }
    }


    // MARK: Views

    private lazy var container = ZStack(alignment: .fill) {
        ZStack(alignment: configuration.alignment) {
            content
                .backgroundColor(configuration.backgroundColor)
                .padding(configuration.edgePadding)
                .backgroundColor(configuration.paddingColor)
        }
    }

    public private(set) lazy var body = ScrollView {
        container
    }
        .configure {
            NSLayoutConstraint.activate([
                container.heightAnchor.constraint(greaterThanOrEqualTo: $0.safeAreaLayoutGuide.heightAnchor)
            ])
        }
        .if(configuration.avoidsKeyboard) {
            $0.avoidKeyboard()
        }
}
