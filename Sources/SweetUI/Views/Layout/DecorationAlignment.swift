import UIKit


public struct DecorationAlignment {

    public let constraintsFactory: (_ base: UIView, _ overlay: UIView) -> [NSLayoutConstraint]

    public init(constraints: @escaping (_ base: UIView, _ decoration: UIView) -> [NSLayoutConstraint]) {
        self.constraintsFactory = constraints
    }
}


public extension DecorationAlignment {

    static var topLeading: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.leadingAnchor.constraint(equalTo: decoration.leadingAnchor),
            base.topAnchor.constraint(equalTo: decoration.topAnchor)]
        }
    }

    static var top: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.centerXAnchor.constraint(equalTo: decoration.centerXAnchor),
            base.topAnchor.constraint(equalTo: decoration.topAnchor)]
        }
    }

    static var topTrailing: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.trailingAnchor.constraint(equalTo: decoration.trailingAnchor),
            base.topAnchor.constraint(equalTo: decoration.topAnchor)]
        }
    }

    static var leading: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.leadingAnchor.constraint(equalTo: decoration.leadingAnchor),
            base.centerYAnchor.constraint(equalTo: decoration.centerYAnchor)]
        }
    }

    static var center: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.centerXAnchor.constraint(equalTo: decoration.centerXAnchor),
            base.centerYAnchor.constraint(equalTo: decoration.centerYAnchor)]
        }
    }

    static var trailing: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.trailingAnchor.constraint(equalTo: decoration.trailingAnchor),
            base.centerYAnchor.constraint(equalTo: decoration.centerYAnchor)]
        }
    }

    static var bottomLeading: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.leadingAnchor.constraint(equalTo: decoration.leadingAnchor),
            base.bottomAnchor.constraint(equalTo: decoration.bottomAnchor)]
        }
    }

    static var bottom: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.centerXAnchor.constraint(equalTo: decoration.centerXAnchor),
            base.bottomAnchor.constraint(equalTo: decoration.bottomAnchor)]
        }
    }

    static var bottomTrailing: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [base.trailingAnchor.constraint(equalTo: decoration.trailingAnchor),
            base.bottomAnchor.constraint(equalTo: decoration.bottomAnchor)]
        }
    }

    static var fill: DecorationAlignment {
        DecorationAlignment { base, decoration in
            [decoration.centerXAnchor.constraint(equalTo: base.centerXAnchor),
            decoration.centerYAnchor.constraint(equalTo: base.centerYAnchor),
            decoration.widthAnchor.constraint(equalTo: base.widthAnchor),
            decoration.heightAnchor.constraint(equalTo: base.heightAnchor)]
        }
    }
}


// MARK: - Factory for complex alignments

public extension DecorationAlignment {

    enum XPosition {
        case left, center, right, leading, trailing

        fileprivate var keyPath: KeyPath<UIView, NSLayoutXAxisAnchor> {
            switch self {
            case .left: \.leftAnchor
            case .center: \.centerXAnchor
            case .right: \.rightAnchor
            case .leading: \.leadingAnchor
            case .trailing: \.trailingAnchor
            }
        }
    }

    enum YPosition {
        case top, center, bottom
        fileprivate var keyPath: KeyPath<UIView, NSLayoutYAxisAnchor> {
            switch self {
            case .top: \.topAnchor
            case .center: \.centerYAnchor
            case .bottom: \.bottomAnchor
            }
        }
    }


    static func align(decorationX: XPosition, decorationY: YPosition, toBaseX baseX: XPosition? = nil, baseY: YPosition? = nil, offset: CGSize = .zero) -> DecorationAlignment {
        DecorationAlignment { base, decoration in
            let decorationXAnchor = decoration[keyPath: decorationX.keyPath]
            let decorationYAnchor = decoration[keyPath: decorationY.keyPath]
            let baseXAnchor = base[keyPath: (baseX ?? decorationX).keyPath]
            let baseYAnchor = base[keyPath: (baseY ?? decorationY).keyPath]
            return [
                decorationXAnchor.constraint(equalTo: baseXAnchor, constant: offset.width),
                decorationYAnchor.constraint(equalTo: baseYAnchor, constant: offset.height),
            ]
        }
    }
}
