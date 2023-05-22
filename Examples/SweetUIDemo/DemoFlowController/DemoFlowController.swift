import Foundation
import UIKit
import SweetUI


class DemoFlowController: NavigationFlowController {

    lazy var rootViewController: UIViewController = ExampleViewController()
}



private final class ExampleViewController: ContentViewController, Presentable {

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
        .configure {
            $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endModal)))
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

static var modalCount = 0

    override func viewDidAppear(_ animated: Bool) {
//        if Self.modalCount < 3 {
//            presentModal()
//        }
        if self.presentingViewController == nil {
            // presentPopover()
            presentModal()
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//                let vc = self.presentedViewController as! ExampleViewController
//                vc.endPresentation(with: .success("BOOM!"), animated: true)
//            }
        }
    }


    // MARK: - Actions

    @objc
    func endModal() {
        endPresentation(with: .success("Hiya!"), animated: true)
    }

    func presentModal() {
        Self.modalCount += 1
        Task {
            do {
                let modal = ExampleViewController()
                modal.view.backgroundColor = .green
                let nav = NavigationController(root: modal)
                try await self.present(nav, animated: true)
                print("Modal completed with value: \("")")
            } catch {
                print("Failed to retrieve value from modal")
            }
            Self.modalCount -= 1
        }
    }

    func presentSheet() {
        Task {
            do {
                let modal = ExampleViewController()
                modal.view.backgroundColor = .yellow
                let value = try await self.presentSheet(modal, animated: true)
                print("Sheet completed with value: \(value)")
            } catch {
                print("Failed to retrieve value from sheet")
            }
        }
    }

    func presentPopover() {
        Task {
            do {
                let modal = ExampleViewController()
                modal.view.backgroundColor = .yellow
                let value = try await self.presentPopover(modal, animated: true) { popover in
                    popover.sourceView = rootView
                }
                print("Sheet completed with value: \(value)")
            } catch {
                print("Failed to retrieve value from sheet")
            }
        }
    }


    func resultForCancelledPresentation() -> Result<String, Error> {
        return .success("Why you no love me 😭!")
    }
}
