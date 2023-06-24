import UIKit


public struct SafeAreaRegions: OptionSet {

    public let rawValue: Int8

    public static let all = Self(rawValue: ~0)
    public static let container = Self(rawValue: 1 << 0)
    public static let keyboard = Self(rawValue: 1 << 1)
    public static let none: Self = []

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }
}


public protocol EdgesIgnoringSafeAreaSupporting: UIView {
    var safeAreaIgnoringRegions: SafeAreaRegions { get }
    var edgesIgnoringSafeArea: UIRectEdge { get }
}


public extension UIRectEdge {
    static let vertical: UIRectEdge = [.top, .bottom]
    static let horizontal: UIRectEdge = [.left, .right]
}


// MARK: - Defaults

public extension EdgesIgnoringSafeAreaSupporting {

    var edgesIgnoringSafeArea: UIRectEdge {
        // We don't use type constrained extensions because a UIScrollView can be passed around as a UIView
        if self is UIScrollView {
            return .all
        }
        return []
    }

    var safeAreaIgnoringRegions: SafeAreaRegions {
        if self is UIScrollView {
            return .none
        }
        return .container
    }
}


// MARK: - Internal UIView additions

extension UIView {

    // We could replace this method by making UIView conform to EdgesIgnoringSafeAreaSupporting but
    // that would mean each view would have a property that provides next no utility.
    static func edgesIgnoringSafeArea(for view: UIView) -> UIRectEdge {
        if let view = view as? EdgesIgnoringSafeAreaSupporting {
            return view.edgesIgnoringSafeArea
        }
        if view is UIScrollView {
            return .all
        }
        if let subview = view.subviews.first {
            return edgesIgnoringSafeArea(for: subview)
        }
        return []
    }

    func addAndFill(subview: UIView, overrideEdgesIgnoringSafeArea: UIRectEdge?) {
        let edgesIgnoringSafeArea = overrideEdgesIgnoringSafeArea ?? Self.edgesIgnoringSafeArea(for: subview)
        self.addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = edgesIgnoringSafeArea.contains(.top) ? self.topAnchor: self.safeAreaLayoutGuide.topAnchor
        let bottomConstraint = edgesIgnoringSafeArea.contains(.bottom) ? self.bottomAnchor: self.safeAreaLayoutGuide.bottomAnchor
        let leftConstraint = edgesIgnoringSafeArea.contains(.left) ? self.leftAnchor: self.safeAreaLayoutGuide.leftAnchor
        let rightConstraint = edgesIgnoringSafeArea.contains(.right) ? self.rightAnchor: self.safeAreaLayoutGuide.rightAnchor

        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topConstraint),
            subview.bottomAnchor.constraint(equalTo: bottomConstraint),
            subview.leftAnchor.constraint(equalTo: leftConstraint),
            subview.rightAnchor.constraint(equalTo: rightConstraint),
        ])
    }
}
