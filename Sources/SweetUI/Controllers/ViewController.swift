import Foundation
import UIKit
import CoreFoundation


public typealias ViewController = _ViewController & ViewControlling


open class _ViewController: UIViewController, _ConnectionProviderImplementation, TraitCollectionDidChangeProvider {

    // MARK: Properties

    let connectionProviderStorage = ConnectionProviderStorage()
    var cancellationsByIdentifier = [AnyHashable: Any]()
    var traitCollectionDidChangeHandlers = [(UITraitCollection?, UITraitCollection) -> Bool]()


    // MARK: Instance life cycle

    public init() {
        super.init(nibName: nil, bundle: nil)
    }    

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @available(*, deprecated, message: "Use viewDidLoad to configure the view.")
    override public func loadView() {
        guard let owner = self as? _ViewControlling else {
            preconditionFailure("_ViewController must conform to _ViewControlling")
        }
        let view = owner._rootView
        self.view = view
    }


    // MARK: View life cycle

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConnectionHandlers(shouldConnect: true)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateConnectionHandlers(shouldConnect: false)
    }

    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        let current = self.traitCollection
        self.traitCollectionDidChangeHandlers = traitCollectionDidChangeHandlers.filter { $0(previous, current) }
    }
}


// MARK: - Cancellable

public extension _ViewController {

    func storeCancellable(_ cancellable: Any, for key: AnyHashable) {
        cancellationsByIdentifier[key] = cancellable
    }

    func discardCancellable(for key: AnyHashable) {
        cancellationsByIdentifier.removeValue(forKey: key)
    }
}


// MARK: - TraitCollectionDidChangeProvider

extension _ViewController {

    public func addTraitCollectionDidChangeHandler(_ handler: @escaping (UITraitCollection?, UITraitCollection) -> Bool) {
        traitCollectionDidChangeHandlers.append(handler)
    }
}
