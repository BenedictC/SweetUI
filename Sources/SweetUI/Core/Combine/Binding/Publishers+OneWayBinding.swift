import Combine


// MARK: - State

public extension Binding {

    func asOneWayBinding() -> OneWayBinding<Output> {
        self
    }
}


public extension CurrentValueSubject where Failure == Never {

    func makeOneWayBinding() -> OneWayBinding<Output> {
        OneWayBinding(publisher: self, get: { self.value })
    }
}


public extension Just {

    func makeOneWayBinding() -> OneWayBinding<Output> {
        OneWayBinding(publisher: self, get: { self.output })
    }
}


public extension Publisher where Failure == Never {

    func makeOneWayBinding(currentValue: Output) -> OneWayBinding<Output> {
        let subject = CurrentValueSubject<Output, Never>(currentValue)
        let cancellable = self.sink { subject.send($0) }

        let result = OneWayBinding(publisher: subject, get: { subject.value })
        result.cancellable = cancellable

        return result
    }
}
