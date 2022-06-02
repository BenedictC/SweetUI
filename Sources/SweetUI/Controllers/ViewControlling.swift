import Foundation
import UIKit


public protocol ViewControlling: _ViewControlling {
    associatedtype View: UIView

    var rootView: View { get }
}


public protocol _ViewControlling: UIViewController {

    var _rootView: UIView { get }
}


public extension ViewControlling {

    var _rootView: UIView { rootView }
}
