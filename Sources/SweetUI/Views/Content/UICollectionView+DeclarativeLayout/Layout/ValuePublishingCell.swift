import UIKit


internal final class ValuePublishingCell<ItemIdentifier>: UICollectionViewCell, ReusableViewConfigurable, CancellableStorageProvider {

    // MARK: Properties

    typealias BodyFactory = ((OneWayBinding<ItemIdentifier>) -> UIView)


    // MARK: Properties

    let cancellableStorage = CancellableStorage()
    private var bindingOptions: BindingOptions = .default
    private var bodyFactory: BodyFactory?
    private var binding: Binding<ItemIdentifier>?


    // MARK: - ReusableViewConfigurable

    func initialize(bindingOptions: BindingOptions, bodyFactory: @escaping BodyFactory) {
        self.bindingOptions = bindingOptions
        self.bodyFactory = bodyFactory
    }

    func configure(using value: ItemIdentifier) {
        CancellableStorage.push(cancellableStorage)
        defer { CancellableStorage.pop(expected: cancellableStorage) }

        if let binding {
            // Use already created
            binding.send(value)
            return
        }
        // Create binding and body
        self.binding = Binding(wrappedValue: value, options: bindingOptions)
        guard let bodyFactory, let binding else {
            preconditionFailure("Misconfigured cell")
        }
        let body = bodyFactory(binding)

        self.contentView.addSubview(body)
        body.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            body.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor),
            body.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor),
            body.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            body.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
                .priority(.almostRequired),
        ])
    }
}
