import Combine


public extension Binding {

    @propertyWrapper
    final class OneWay: _MutableBinding<Output> { // Inherits Publisher from OneWayBinding

        // MARK: Properties

        // ProjectedValue

        public var projectedValue: OneWayBinding<Output> { self }


        // WrappedValue

        @available(*, unavailable, message: "@Binding.OneWay is only available on properties of classes")
        public var wrappedValue: Output {
            get { getter() }
            set { receiveValue(newValue) }
        }

        // Subscript to allow classes to access the wrappedValue
        public static subscript<EnclosingObject: AnyObject>(
            _enclosingInstance object: EnclosingObject,
            wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingObject, Output>,
            storage storageKeyPath: ReferenceWritableKeyPath<EnclosingObject, Binding<Output>.OneWay>
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

    }

}
