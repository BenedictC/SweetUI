import Foundation
import UIKit


public typealias ContentViewController = _ContentViewController & ContentViewControlling


public protocol ContentViewControlling: _ContentViewControlling, ViewControlling  {

}


public protocol _ContentViewControlling: _ViewControlling {

}


public extension _ContentViewControlling {

}


// MARK: -

open class _ContentViewController: _ViewController {

}
