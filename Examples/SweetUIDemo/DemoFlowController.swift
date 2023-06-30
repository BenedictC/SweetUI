import Foundation
import UIKit
import SweetUI
import Combine


class DemoFlowController: FlowController {

    lazy var containerViewController = UITabBarController {
        UINavigationController {
            FormViewController()
        }.configure { $0.tabBarItem.title = "Form" }
        UINavigationController {
            PresentationsViewController()
        }.configure { $0.tabBarItem.title = "Modal" }
        UINavigationController {
            CollectionViewController()
        }.configure { $0.tabBarItem.title = "Collection" }
//        UINavigationController {
//            OneOfViewController()
//        }.configure { $0.tabBarItem.title = "OneOf" }
    }
}


class OneOfViewController: ViewController {

    let publisher = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()
        .map { Int($0.timeIntervalSince1970) }

    private(set) lazy var rootView = OneOf(for: publisher) {
        Component(for: { $0 % 5 == 0 }) {
            UILabel(text: "By 5")
                .backgroundColor(.purple)
        }
        Component(for: { $0 % 4 == 0 }) {
            UILabel(text: "By 4")
                .backgroundColor(.green)
        }
        Component(for: { $0 % 3 == 0 }) {
            UILabel(text: "By 3")
                .backgroundColor(.brown)
        }
        Component<Int>.default {
            UILabel()
                .assign(to: \.text, from: $0.map { "\($0)" })
                .backgroundColor(.lightGray)
        }
    }
}
