import Foundation
import Combine


// MARK: - SubscriberFactory

public struct SubscriberFactory<C: CancellablesStorageProvider, P: Publisher> where P.Failure == Never {

    private let cancellablesStorageProvider: C
    private let cancellableIdentifier: AnyHashable
    private let publisher: P

    init(cancellablesStorageProvider: C, cancellableIdentifier: AnyHashable = UUID().uuidString, publisher: P) {
        self.cancellablesStorageProvider = cancellablesStorageProvider
        self.cancellableIdentifier = cancellableIdentifier
        self.publisher = publisher
    }

    func makeSubscriber<T: AnyObject>(with object: T, sink handler: @escaping (T, C, P.Output) -> Void) {
        let storageProvider = self.cancellablesStorageProvider
        let cancellable = publisher.sink { [weak storageProvider, weak object] value in
            guard let storageProvider, let object else {
                storageProvider?.discardCancellable(for: cancellableIdentifier)
                return
            }
            handler(object, storageProvider, value)
        }
        cancellablesStorageProvider.storeCancellable(cancellable, for: cancellableIdentifier)
    }

    func makeSubscriber(sink handler: @escaping (C, P.Output) -> Void) {
        let storageProvider = self.cancellablesStorageProvider
        let cancellable = publisher.sink { [weak storageProvider] value in
            guard let storageProvider else { return }
            handler(storageProvider, value)
        }
        cancellablesStorageProvider.storeCancellable(cancellable, for: cancellableIdentifier)
    }

    func makeCancellable(with factory: (P) -> AnyCancellable) {
        let cancellable = factory(publisher)
        cancellablesStorageProvider.storeCancellable(cancellable, for: cancellableIdentifier)
    }
}


// MARK: - CancellablesStorageProvider factories

public extension CancellablesStorageProvider {

    func publisher<ValuePublisher: Publisher>(_ publisher: ValuePublisher) -> SubscriberFactory<Self, ValuePublisher> {
        SubscriberFactory(cancellablesStorageProvider: self, publisher: publisher)
    }

    func publisher<ValuePublisher: Publisher>(_ closure: (Self) -> ValuePublisher) -> SubscriberFactory<Self, ValuePublisher> {
        SubscriberFactory(cancellablesStorageProvider: self, publisher: closure(self))
    }
}


// These are just alias to publisher(...) but with semantically clearer name
public extension CancellablesStorageProvider {

    func subject<ValueSubject: Subject>(_ subject: ValueSubject) -> SubscriberFactory<Self, ValueSubject> {
        SubscriberFactory(cancellablesStorageProvider: self, publisher: subject)
    }

    func subject<ValueSubject: Subject>(_ closure: (Self) -> ValueSubject) -> SubscriberFactory<Self, ValueSubject> {
        SubscriberFactory(cancellablesStorageProvider: self, publisher: closure(self))
    }
}


public extension ViewModelProvider where Self: CancellablesStorageProvider {

    func viewModel<ValuePublisher: Publisher>(_ publisherKeyPath: KeyPath<ViewModel, ValuePublisher>) -> SubscriberFactory<Self, ValuePublisher> {
        SubscriberFactory(cancellablesStorageProvider: self, publisher: viewModel[keyPath: publisherKeyPath])
    }
}


public extension CancellablesStorageProvider where Self: ViewModelProvider, ViewModel: ViewValueSubject {
    
    func value<Value>(_ valueKeyPath: KeyPath<ViewModel.Output, Value>) -> SubscriberFactory<Self, AnyPublisher<Value, Never>> {
        let publisher = self.viewModel!
            .map { $0[keyPath: valueKeyPath] }
            .eraseToAnyPublisher()
        return SubscriberFactory(cancellablesStorageProvider: self, publisher: publisher)
    }    
}


// MARK: - ValueParameter

//public extension ViewModelProvider where ViewModel: ViewValueSubject {
//
//    func value<Context, Value>(_ valueKeyPath: KeyPath<ViewModel.Output, Value>) -> ValueParameter<Self, Context, ViewState<Value>> {
//        return ValueParameter<Self, Context, ViewState<Value>>(root: self, valueFactory: { $0.root.viewModel!.map(valueKeyPath).eraseToAnyPublisher() })
//    }
//}


//public final class ValueParameter<Root: AnyObject, Context: AnyObject, Value> {
//
//    // MARK: Types
//
//    public struct Arguments {
//        public let root: Root
//        public let context: Context
//    }
//    public typealias ValueFactory = (Arguments) -> Value
//
//
//    // MARK: Properties
//
//    internal let identifier = UUID()
//    public private(set) weak var root: Root?
//    internal weak var context: Context?
//    private var valueFactory: ValueFactory?
//    internal var invalidationHandler: (() -> Void)?
//
//
//    // MARK: Instance life cycle
//
//    init(root: Root, valueFactory: @escaping ValueFactory) {
//        self.root = root
//        self.valueFactory = valueFactory
//    }
//
//
//    // MARK: Execution
//
//    func makeValue() -> Value? {
//        guard let root = root,
//              let context = context
//        else {
//            return nil
//        }
//        let arguments = Arguments(root: root, context: context)
//        return valueFactory?(arguments)
//    }
//
//    public func invalidate() {
//        invalidationHandler?()
//        invalidationHandler = nil
//    }
//}
