import Foundation
import UIKit
import SweetUI


class DemoFlowController: NavigationFlowController {

    lazy var rootViewController: UIViewController = ExampleViewController()
}



private class ExampleViewController: ContentViewController {

    // MARK: - State

    @State var message = ""


    // MARK: - View

    lazy var rootView = ZStack(alignment: .center) {
        VStack {
            UILabel()
                .text("Hiya!")
                .font(.preferredFont(forTextStyle: .headline))
            UILabel()
                .assign(to: \.text, from: $message)
        }
    }


    // MARK: - Life cycle

    override init() {
        super.init()

        collectCancellables {
            Timer.publish(every: 0.5, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] in
                    self?.message = "\($0)"
                }
        }
    }
}
