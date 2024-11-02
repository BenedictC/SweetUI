import Foundation
import Combine
import UIKit


// MARK: - ViewController

public typealias ViewController = _ViewController & ViewControllerRequirements


// MARK: - Associated Types

public protocol ViewControllerRequirements: _ViewControllerRequirements {
    associatedtype View: UIView
    
    var rootView: View { get }
}

@MainActor
public protocol _ViewControllerRequirements: _ViewController, CancellableStorageProvider {
    var _rootView: UIView { get }
    func awake()
}


// MARK: - Implementation

public extension ViewControllerRequirements {
    var _rootView: UIView { rootView }
    func awake() { }
}


open class _ViewController: UIViewController, TraitCollectionChangesProvider {
    
    // MARK: Types
    
    public enum EditMode {
        case active, inactive
        init(value: Bool) { self = value ? .active : .inactive }
    }
    
    public enum CancellableKey {
        public static let awake = CancellableStorageKey.unique()
        public static let loadView = CancellableStorageKey.unique()
    }
    
    
    // MARK: Properties
    
    private lazy var traitCollectionChangesController = TraitCollectionChangesController(initialTraitCollection: traitCollection)
    public var traitCollectionChanges: AnyPublisher<TraitCollectionChanges, Never> { traitCollectionChangesController.traitCollectionChanges }
    @Published public private(set) var editMode: EditMode = .inactive
    fileprivate lazy var defaultCancellableStorage = CancellableStorage()

    
    // MARK: Instance life cycle
    
    public init() {
        super.init(nibName: nil, bundle: nil)

        guard let owner = self as? _ViewControllerRequirements else {
            preconditionFailure("_ViewController must conform to _ViewControllerRequirements")
        }
        // Initialize a barItems
        owner.collectCancellables(with: CancellableKey.awake) {
            let advice = "Check that closures used to make the barItem that reference the view controller do so with weak references."
            detectPotentialRetainCycle(of: self, advice: advice) { owner.awake() }  // Force load barItems
        }
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: View life cycle
    
    @available(*, deprecated, message: "Use viewDidLoad to configure the view.")
    override public func loadView() {
        guard let owner = self as? _ViewControllerRequirements else {
            preconditionFailure("_ViewController must conform to _ViewControllerRequirements")
        }
        owner.collectCancellables(with: CancellableKey.loadView) {
            guard let owner = self as? _ViewControllerRequirements else {
                preconditionFailure("_ViewController must conform to _ViewControllerRequirements")
            }
            // If the view ignores all safe areas then it can be used as the self.view directly
            let advice = "Check that closures within the view that reference the view controller are weak, e.g. `button.on(.primaryActionTriggered) { [weak self] _ in self?.submit() }`"
            let rootView = detectPotentialRetainCycle(of: self, advice: advice) { owner._rootView }
            let edgesToIgnore = UIView.edgesIgnoringSafeArea(for: rootView)
            let requiresContainer = edgesToIgnore != .all
            if requiresContainer {
                let container = rootView.ignoresSafeArea(edges: edgesToIgnore)
                self.view = container
            } else {
                self.view = rootView
            }
            
            let shouldSetBackground = self.view.backgroundColor == nil
            if shouldSetBackground {
                self.view.backgroundColor = .systemBackground
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        traitCollectionChangesController.send(previous: previous, current: traitCollection)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.post(name: .viewDidAppear, object: self, userInfo: nil)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.didDisappear()
    }
    
    open override func setEditing(_ value: Bool, animated: Bool) {
        super.setEditing(value, animated: animated)
        editMode = EditMode(value: value)
    }
}


// MARK: - CancellableStorageProvider default implementation

extension CancellableStorageProvider where Self: ViewController {
    public var cancellableStorage: CancellableStorage { defaultCancellableStorage }
}
