import Foundation
import UIKit
import SweetUI
import Combine


class DemoFlowController: FlowController {

    lazy var containerViewController = UITabBarController {
        NavigationController {
            FormViewController()
        }.configure { $0.tabBarItem.title = "Form" }
        NavigationController {
            PresentationsViewController()
        }.configure { $0.tabBarItem.title = "Modal" }
        NavigationController {
            CollectionViewController()
        }.configure { $0.tabBarItem.title = "Collection" }
    }
}
