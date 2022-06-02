import Foundation
import UIKit


public final class ScrollView: UIScrollView {

    // MARK: - Properties

    public let axes: Axis


    // MARK: - Instance life cycle

    init(axes: Axis = .vertical, keyboardDismissMode: UIScrollView.KeyboardDismissMode? = nil, delegate: UIScrollViewDelegate? = nil, content: UIView) {
        self.axes = axes
        super.init(frame: .zero)
        if let keyboardDismissMode = keyboardDismissMode {
            self.keyboardDismissMode = keyboardDismissMode
        }
        self.delegate = delegate

        self.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            content.leftAnchor.constraint(equalTo: contentLayoutGuide.leftAnchor),
            content.rightAnchor.constraint(equalTo: contentLayoutGuide.rightAnchor),
        ])
        let shouldConstrainWidth = !axes.contains(.horizontal)
        if shouldConstrainWidth {
            NSLayoutConstraint.activate([
                content.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor)
            ])
        }
        let shouldConstrainHeight = !axes.contains(.vertical)
        if shouldConstrainHeight {
            NSLayoutConstraint.activate([
                content.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor)
            ])
        }
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


public extension ScrollView {

    convenience init(axes: Axis = .vertical, keyboardDismissMode: UIScrollView.KeyboardDismissMode? = nil, delegate: UIScrollViewDelegate? = nil, contentBuilder: () -> UIView) {
        let content = contentBuilder()
        self.init(axes: axes, keyboardDismissMode: keyboardDismissMode, delegate: delegate, content: content)
    }
}
