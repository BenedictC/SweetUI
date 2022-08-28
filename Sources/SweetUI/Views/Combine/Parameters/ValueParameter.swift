import Foundation
import Combine


// MARK: - ViewAvailabilityProvider factories

public extension NSObjectProtocol where Self: ViewAvailabilityProvider {

    func publisher<Context, ValuePublisher: Publisher>(_ closure: @escaping () -> ValuePublisher) -> ValueParameter<Self, Context, ValuePublisher> {
        ValueParameter(root: self, valueFactory: { _ in closure() })
    }

    func publisher<Context, ValuePublisher: Publisher>(_ closure: @escaping (Self) -> ValuePublisher) -> ValueParameter<Self, Context, ValuePublisher> {
        ValueParameter(root: self, valueFactory: { closure($0.root) })
    }

    func publisher<Context, ValuePublisher: Publisher>(_ closure: @escaping (Self, Context) -> ValuePublisher) -> ValueParameter<Self, Context, ValuePublisher> {
        ValueParameter(root: self, valueFactory: { closure($0.root, $0.context) })
    }

    func publisher<Context, ValuePublisher: Publisher>(at publisherKeyPath: KeyPath<Self, ValuePublisher>) -> ValueParameter<Self, Context, ValuePublisher> {
        return ValueParameter(root: self, valueFactory: { $0.root[keyPath: publisherKeyPath] })
    }
}


public extension NSObjectProtocol where Self: ViewAvailabilityProvider {

    func subject<Context, ValueSubject: Subject>(_ closure: @escaping () -> ValueSubject) -> ValueParameter<Self, Context, ValueSubject> {
        ValueParameter(root: self, valueFactory: { _ in closure() })
    }

    func subject<Context, ValueSubject: Subject>(_ closure: @escaping (Self) -> ValueSubject) -> ValueParameter<Self, Context, ValueSubject> {
        ValueParameter(root: self, valueFactory: { closure($0.root) })
    }

    func subject<Context, ValueSubject: Subject>(_ closure: @escaping (Self, Context) -> ValueSubject) -> ValueParameter<Self, Context, ValueSubject> {
        ValueParameter(root: self, valueFactory: { closure($0.root, $0.context) })
    }

    func subject<Context, ValueSubject: Subject>(at subjectKeyPath: KeyPath<Self, ValueSubject>) -> ValueParameter<Self, Context, ValueSubject> {
        return ValueParameter(root: self, valueFactory: { $0.root[keyPath: subjectKeyPath] })
    }

    func subject<Context, Value>(property: ReferenceWritableKeyPath<Self, Value>, publisher publisherKeyPath: KeyPath<Self, Published<Value>.Publisher>) -> ValueParameter<Self, Context, AnySubject<Value, Never>> {
        return ValueParameter(root: self) { arguments in
            let root = arguments.root
            let publisher = root[keyPath: publisherKeyPath]
            let subject = ViewBinding(for: root, property, publisher: publisher)
            return subject
        }
    }
}


public extension ViewModelProvider {

    func viewModel<Context, ValuePublisher: Publisher>(_ publisherKeyPath: KeyPath<ViewModel, ValuePublisher>) -> ValueParameter<Self, Context, ValuePublisher> {
        return ValueParameter(root: self, valueFactory: { $0.root.viewModel[keyPath: publisherKeyPath] })
    }
}


public extension ViewModelProvider where ViewModel: ViewValueSubject {

    func value<Context, Value>(_ valueKeyPath: KeyPath<ViewModel.Output, Value>) -> ValueParameter<Self, Context, ViewState<Value>> {
        return ValueParameter<Self, Context, ViewState<Value>>(root: self, valueFactory: { $0.root.viewModel!.map(valueKeyPath).eraseToAnyPublisher() })
    }
}


// MARK: - ValueParameter

public final class ValueParameter<Root: AnyObject, Context: AnyObject, Value> {

    // MARK: Types

    public struct Arguments {
        public let root: Root
        public let context: Context
    }
    public typealias ValueFactory = (Arguments) -> Value


    // MARK: Properties

    internal let identifier = UUID()
    public private(set) weak var root: Root?
    internal weak var context: Context?
    private var valueFactory: ValueFactory?
    internal var invalidationHandler: (() -> Void)?


    // MARK: Instance life cycle

    init(root: Root, valueFactory: @escaping ValueFactory) {
        self.root = root
        self.valueFactory = valueFactory
    }


    // MARK: Execution

    func makeValue() -> Value? {
        guard let root = root,
              let context = context
        else {
            return nil
        }
        let arguments = Arguments(root: root, context: context)
        return valueFactory?(arguments)
    }

    public func invalidate() {
        invalidationHandler?()
        invalidationHandler = nil
    }
}
