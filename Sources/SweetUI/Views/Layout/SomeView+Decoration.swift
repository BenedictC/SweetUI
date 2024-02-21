import Foundation
import UIKit


public extension SomeView {

    typealias DecorationContainer<V: UIView, O: UIView> = Container<(view: V, overlay: O)>
}


public struct DecorationAlignment {

    public let constraintsFactory: (_ base: UIView, _ overlay: UIView) -> [NSLayoutConstraint]

    public init(@ArrayBuilder<NSLayoutConstraint> constraints: @escaping (_ base: UIView, _ overlay: UIView) -> [NSLayoutConstraint]) {
        self.constraintsFactory = constraints
    }
}


// MARK: - Overlay

public extension SomeView {

    func overlay<O: UIView>(alignment: DecorationAlignment, view: O) -> DecorationContainer<Self, O> {
        overlay(alignment: alignment, view: { view })
    }

    func overlay<O: UIView>(alignment: DecorationAlignment, view overlayBuilder: () -> O) -> DecorationContainer<Self, O> {
        let overlay = overlayBuilder()
        let container = DecorationContainer(content: (self, overlay))

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


// MARK: - Background

public extension SomeView {

    func background<O: UIView>(alignment: DecorationAlignment = .fill, view: O) -> DecorationContainer<Self, O> {
        overlay(alignment: alignment, view: { view })
    }

    func background<O: UIView>(alignment: DecorationAlignment, view backgroundBuilder: () -> O) -> DecorationContainer<Self, O> {
        let background = backgroundBuilder()
        let container = DecorationContainer(content: (self, background))

        self.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self)
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: container.leftAnchor),
            self.rightAnchor.constraint(equalTo: container.rightAnchor),
            self.topAnchor.constraint(equalTo: container.topAnchor),
            self.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        background.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(background)
        container.sendSubviewToBack(background)
        let overlayConstraints = alignment.constraintsFactory(self, background)
        NSLayoutConstraint.activate(overlayConstraints)

        return container
    }
}


// MARK: - In Bounds

public extension DecorationAlignment {

    static var topLeading: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.leadingAnchor.constraint(equalTo: overlay.leadingAnchor)
            base.topAnchor.constraint(equalTo: overlay.topAnchor)
        }
    }

    static var top: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
            base.topAnchor.constraint(equalTo: overlay.topAnchor)
        }
    }

    static var topTrailing: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.trailingAnchor.constraint(equalTo: overlay.trailingAnchor)
            base.topAnchor.constraint(equalTo: overlay.topAnchor)
        }
    }

    static var leading: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.leadingAnchor.constraint(equalTo: overlay.leadingAnchor)
            base.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        }
    }

    static var center: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
            base.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        }
    }

    static var trailing: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.trailingAnchor.constraint(equalTo: overlay.trailingAnchor)
            base.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        }
    }

    static var bottomLeading: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.leadingAnchor.constraint(equalTo: overlay.leadingAnchor)
            base.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
        }
    }

    static var bottom: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.centerXAnchor.constraint(equalTo: overlay.centerXAnchor)
            base.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
        }
    }

    static var bottomTrailing: DecorationAlignment {
        DecorationAlignment { base, overlay in
            base.trailingAnchor.constraint(equalTo: overlay.trailingAnchor)
            base.bottomAnchor.constraint(equalTo: overlay.bottomAnchor)
        }
    }

    static var fill: DecorationAlignment {
        DecorationAlignment { base, decoration in
            decoration.centerXAnchor.constraint(equalTo: base.centerXAnchor)
            decoration.centerYAnchor.constraint(equalTo: base.centerYAnchor)
            decoration.widthAnchor.constraint(equalTo: base.widthAnchor)
            decoration.heightAnchor.constraint(equalTo: base.heightAnchor)
        }
    }
}
