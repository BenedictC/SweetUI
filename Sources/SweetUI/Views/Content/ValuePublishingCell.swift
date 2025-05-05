// MARK: - ValuePublishingCell

internal final class ValuePublishingCell<Value>: UICollectionViewCell, ReusableViewConfigurable, CancellableStorageProvider {

    // MARK: Properties

    typealias BodyProvider = ((UICollectionViewCell, OneWayBinding<Value>) -> UIView)


    // MARK: Properties

    let cancellableStorage = CancellableStorage()
    private var bindingOptions: BindingOptions = .default
    private var bodyProvider: BodyProvider?
    private var binding: Binding<Value>?


    // MARK: - ReusableViewConfigurable

    func initialize(bindingOptions: BindingOptions, bodyProvider: @escaping BodyProvider) {
        self.bindingOptions = bindingOptions
        self.bodyProvider = bodyProvider
    }

    func configure(using value: Value) {
        CancellableStorage.push(cancellableStorage)
        defer { CancellableStorage.pop(expected: cancellableStorage) }

        if let binding {
            // Use already created
            binding.send(value)
            return
        }
        // Create binding and body
        self.binding = Binding(wrappedValue: value, options: bindingOptions)
        guard let bodyProvider, let binding else {
            preconditionFailure("Misconfigured cell")
        }
        let body = bodyProvider(self, binding)

        self.contentView.addSubview(body)
        body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            body.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            body.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).priority(.almostRequired),
            body.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor).priority(.almostRequired),
        ])
    }
}
