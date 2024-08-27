import Combine


public extension Binding {

    @propertyWrapper
    final class OneWay: _MutableBinding<Output> { // Inherits Publisher from OneWayBinding

        // MARK: Properties

        public var projectedValue: OneWayBinding<Output> { self }

        override public var wrappedValue: Output {
            get { getter() }
            set { subject.send(newValue) }
        }
    }

}
