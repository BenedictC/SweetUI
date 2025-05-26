//import Foundation
//import UIKit
//
//
//public final class OneOf: UIView {
//
//    // MARK: Properties
//
//    private lazy var cancellableStorage = CancellableStorage()
//
//
//    // MARK: Instance life cycle
//
//    public init<Value>(
//        value initialPublisher: some Publisher<Value, Never>,
//        dropDuplicateValues: Bool = true,
//        content contentFactory: @escaping (Value)-> UIView
//    ) {
//        // Configure initial view state
//        super.init(frame: .zero)
//        NSLayoutConstraint.activate([
//            // Default to no size
//            widthAnchor.constraint(equalToConstant: 0).priority(.lowest),
//            heightAnchor.constraint(equalToConstant: 0).priority(.lowest)
//        ])
//
//        // Create publisher
//        let publisher: any Publisher<Value, Never>
//        if dropDuplicateValues {
//            // This is a little hacky but unlikely to be a problem
//            publisher = BindingOptions.dropDuplicates.decorate(initialPublisher)
//        } else {
//            publisher = initialPublisher
//        }
//
//        // Configure when the views are shown
//        publisher.sink { [weak self] value in
//            guard let self else { return }
//            CancellableStorage.push(self.cancellableStorage)
//            defer { CancellableStorage.pop(expected: self.cancellableStorage) }
//
//            let subview = contentFactory(value)
//            subview.translatesAutoresizingMaskIntoConstraints = false
//            self.addSubview(subview)
//            NSLayoutConstraint.activate([
//                subview.leftAnchor.constraint(equalTo: self.leftAnchor),
//                subview.rightAnchor.constraint(equalTo: self.rightAnchor),
//                subview.topAnchor.constraint(equalTo: self.topAnchor),
//                subview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            ])
//        }
//        .store(in: cancellableStorage)
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
