import Combine


public final class ValueBinding<Output>: _MutableBinding<Output>, Subject {

    // MARK: Properties

    var ancestorSetter: ((Output) -> Void)?


    // MARK: Instance life cycle

    init(currentValueSubject: CurrentValueSubject<Output, Never>, options: BindingOptions, setter: @escaping (Output) -> Void) {
        self.ancestorSetter = setter
        super.init(currentValueSubject: currentValueSubject, options: options)
    }


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


    // MARK: Setter

    override func receiveValue(_ fresh: Output) {
        if let ancestorSetter {
            ancestorSetter(fresh)
            return
        }
        super.receiveValue(fresh)
    }
}
