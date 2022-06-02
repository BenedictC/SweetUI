import Foundation
import UIKit


// MARK: -

public typealias FlowController = _FlowController & FlowSupporting


public protocol FlowSupporting: ContentViewControlling, _FlowSupporting {

    associatedtype ContainerViewController: UIViewController
    associatedtype View = UIView

    var containerViewController: ContainerViewController { get }
}


public protocol _FlowSupporting: _ContentViewControlling {

    var _containerViewController: UIViewController { get }
    var childViewContainer: UIView { get }
}


// MARK: -

public extension FlowSupporting {

    var rootView: View {
        guard isViewLoaded else {
            return View()
        }
        guard let view = view as? View else {
            preconditionFailure("\(type(of: self)).view is of unexpected type. Expected \(View.self) but found \(type(of: view)).")
        }
        return view
    }
}


// MARK: - Implementation details

public extension FlowSupporting {

    var childViewContainer: UIView { rootView }
    var _rootView: UIView { rootView }
    var _containerViewController: UIViewController { containerViewController }
}


open class _FlowController: _ContentViewController {

    @available(*, unavailable, message: "Use viewDidLoad to configure the view.")
    override public func loadView() {
        guard let flow = self as? _FlowSupporting else {
            preconditionFailure("_FlowController subclasses must conform to _FlowSupporting.")
        }

        self.view = flow._rootView

        let childVC = flow._containerViewController
        guard let childView = childVC.view else {
            preconditionFailure("ViewController.view must not be nil.")
        }
        childVC.willMove(toParent: self)

        let container = flow.childViewContainer
        container.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: container.topAnchor),
            childView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            childView.leftAnchor.constraint(equalTo: container.leftAnchor),
            childView.rightAnchor.constraint(equalTo: container.rightAnchor),
        ])

        addChild(childVC)
    }
}
