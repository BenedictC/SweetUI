import Combine

public typealias BindingOneWay<T> = Binding<T>.OneWay


@propertyWrapper
public final class Binding<Output>: _MutableBinding<Output>, Subject {
    
    // MARK: Properties

    @available(*, unavailable, message: "@Binding is only available on properties of classes")
    public var wrappedValue: Output {
        get { getter() }
        set { receiveValue(newValue) }
    }
    public var projectedValue: Binding<Output> { self }

    var ancestorSetter: ((Output) -> Void)?


    // MARK: Instance life cycle

    // Init is handled by _MutableBinding


    // MARK: Subject
    
    public func send(_ value: Output) {
        receiveValue(value)
    }
    
    public func send(completion: Subscribers.Completion<Never>) {
        subject.send(completion: completion)
    }
    
    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }


    // MARK: Accessors

    // Subscript to allow classes to access the wrappedValue
    public static subscript<EnclosingObject: AnyObject>(
        _enclosingInstance object: EnclosingObject,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingObject, Output>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingObject, Binding<Output>>
    ) -> Output {
        get {
            let binding = object[keyPath: storageKeyPath]
            return binding.getter()
        }
        set {
            let binding = object[keyPath: storageKeyPath]
            binding.receiveValue(newValue)
        }
    }

    override func receiveValue(_ fresh: Output) {
        if let ancestorSetter {
            ancestorSetter(fresh)
            return
        }
        super.receiveValue(fresh)
    }


    // MARK: Dynamic member lookup (for creating binding to reference types)

    public subscript<T>(dynamicMember bindingKeyPath: KeyPath<Output, some Binding<T>>) -> Binding<T> {
        // Create the initial state
        let initialValue = self.value[keyPath: bindingKeyPath].value
        let subject = CurrentValueSubject<T, Never>(initialValue)

        let result = Binding<T>(currentValueSubject: subject, options: .default)
        result.ancestorSetter = { (updatedChild: T) -> Void in
            let bindingOnSelf = self.value[keyPath: bindingKeyPath]
            bindingOnSelf.value = updatedChild
            self.receiveValue(self.value)
        }

        var previousCancellable: AnyCancellable?
        // when self emits a new value ...
        let cancellable = self.sink { [weak result] rootObject in
            _ = self // retain the previous Binding but don't retain the output as that would great a retain cycle
            guard let result else {
                return
            }
            // ... we need to re-construct the value we were binding to
            let childBinding = rootObject[keyPath: bindingKeyPath]
            if let previousCancellable {
                result.cancellables.remove(previousCancellable)
                previousCancellable.cancel()
            }
            let freshCancellable = childBinding.sink { childObject in
                subject.send(childObject)
            }
            result.cancellables.insert(freshCancellable)
            previousCancellable = freshCancellable
            // Send the child this may have already occured
            let updatedChild = rootObject[keyPath: bindingKeyPath].value
            subject.send(updatedChild)
        }
        result.cancellables.insert(cancellable)

        return result
    }

    public subscript<T>(_ propertyKeyPath: WritableKeyPath<Output, T>) -> ValueBinding<T> {
        // Create the initial state
        let initialValue = self.value[keyPath: propertyKeyPath]
        let subject = CurrentValueSubject<T, Never>(initialValue)

        let result = ValueBinding<T>(currentValueSubject: subject, options: self.options, setter: { (updated: T) in
            var newValue = self.value
            newValue[keyPath: propertyKeyPath] = updated
            self.value = newValue
            self.receiveValue(self.value)
        })

        // when self emits a new value ...
        let cancellable = self.sink { rootObject in
            _ = self // retain the previous Binding but don't retain the output as that would great a retain cycle
            // ... we need to re-construct the value we were binding to
            let property = rootObject[keyPath: propertyKeyPath]
            subject.send(property)
        }
        result.cancellables.insert(cancellable)

        return result
    }
}



public extension CurrentValueSubject where Failure == Never {

    func makeBinding(options: BindingOptions = .default) -> Binding<Output> {
        Binding(currentValueSubject: self, options: options)
    }
}
