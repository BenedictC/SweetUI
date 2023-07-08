import Foundation
import UIKit


// MARK: - Core

public extension SomeView {

    typealias OverlayContainer<V: UIView, O: UIView> = Container<(view: V, overlay: O)>

    func overlay<O: UIView>(alignment: OverlayAlignment, view overlayBuilder: () -> O) -> OverlayContainer<Self, O> {
        let overlay = overlayBuilder()
        let container = OverlayContainer(content: (self, overlay))

        self.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: container.leftAnchor),
            self.rightAnchor.constraint(equalTo: container.rightAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        overlay.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(overlay)
        let overlayConstraints = alignment.constraintsFactory(self, overlay)
        NSLayoutConstraint.activate(overlayConstraints)

        return container
    }
}


public struct OverlayAlignment {

    public let constraintsFactory: (_ base: UIView, _ overlay: UIView) -> [NSLayoutConstraint]

    public init(@ConstraintsBuilder constraintsFactory: @escaping (_ base: UIView, _ overlay: UIView) -> [NSLayoutConstraint]) {
        self.constraintsFactory = constraintsFactory
    }
}


// MARK: - In Bounds

public extension OverlayAlignment {

    static var topLeading: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.leadingAnchor.constraint(equalTo: overlay.leadingAnchor)
            base.topAnchor.constraint(equalTo: overlay.topAnchor)
        }
    }

    static var top: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
            base.topAnchor.constraint(equalTo: overlay.topAnchor)
        }
    }

    static var topTrailing: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.trailingAnchor.constraint(equalTo: overlay.trailingAnchor)
            base.topAnchor.constraint(equalTo: overlay.topAnchor)
        }
    }

    static var leading: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.leadingAnchor.constraint(equalTo: overlay.leadingAnchor)
            base.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        }
    }

    static var center: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
            base.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        }
    }

    static var trailing: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.trailingAnchor.constraint(equalTo: overlay.trailingAnchor)
            base.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        }
    }

    static var bottomLeading: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.leadingAnchor.constraint(equalTo: overlay.leadingAnchor)
            base.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
        }
    }

    static var bottom: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
            base.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
        }
    }

    static var bottomTrailing: OverlayAlignment {
        OverlayAlignment { base, overlay in
            base.trailingAnchor.constraint(equalTo: overlay.trailingAnchor)
            base.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
        }
    }
}
