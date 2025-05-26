
// MARK: - ValuePublishingCell

internal final class ValuePublishingCell<Value>: UICollectionViewCell, ReusableViewConfigurable, CancellableStorageProvider {

    // MARK: Properties

    typealias BodyProvider = ((UICollectionViewCell, AnyPublisher<Value, Never>) -> UIView)


    // MARK: Properties

    let cancellableStorage = CancellableStorage()
    private var bodyProvider: BodyProvider?
    @Published private var value: Value!


    // MARK: - ReusableViewConfigurable

    func initialize(bodyProvider: @escaping BodyProvider) {
        self.bodyProvider = bodyProvider
    }

    func configure(withValue freshValue: Value) {
        let isInitialized = value != nil
        if isInitialized {
            self.value = freshValue
            return
        }

        // Create binding and body
        CancellableStorage.push(cancellableStorage)
        defer { CancellableStorage.pop(expected: cancellableStorage) }
        
        self.value = freshValue
        guard let bodyProvider else {
            preconditionFailure("Misconfigured cell")
        }
        let body = bodyProvider(self, $value.map { $0! }.eraseToAnyPublisher())

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
