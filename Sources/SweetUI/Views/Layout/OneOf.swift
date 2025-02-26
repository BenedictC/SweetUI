import Foundation
import UIKit
import Combine


// MARK: - OneOf

public struct Component<Output> {
    public let predicate: (Output) -> Bool
    public let view: UIView

    init(predicate: @escaping (Output) -> Bool, view: UIView) {
        self.predicate = predicate
        self.view = view
    }
}


public final class OneOf: UIView {

    // MARK: Properties

    var cancellable: AnyCancellable!


    // MARK: Instance life cycle

    public init<Output>(publisher: some Publisher<Output, Never>, components: [Component<Output>]) {
        super.init(frame: .zero)
        NSLayoutConstraint.activate([
            // Default to no size
            widthAnchor.constraint(equalToConstant: 0).priority(.lowest),
            heightAnchor.constraint(equalToConstant: 0).priority(.lowest)
        ])

        // Configure when the views are shown
        cancellable = publisher.sink { [weak self] value in
            guard let self else { return }
            let visibleViewIndex = components.firstIndex(where: { $0.predicate(value) })

            for (index, component) in components.enumerated() {
                let isWinner = index == visibleViewIndex
                let subview = component.view
                guard isWinner else {
                    subview.removeFromSuperview()
                    continue
                }
                if subview.superview == self { return }
                subview.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(subview)
                NSLayoutConstraint.activate([
                    subview.leftAnchor.constraint(equalTo: self.leftAnchor),
                    subview.rightAnchor.constraint(equalTo: self.rightAnchor),
                    subview.topAnchor.constraint(equalTo: self.topAnchor),
                    subview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                ])
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Result Builder

public extension OneOf {

    convenience init<Output>(
        for publisher: some Publisher<Output, Never>,
        @OneOfComponentsBuilder builder contentBuilder: () -> [Component<Output>]
    ) {
        let components = OneOfComponentsBuilder.with(publisher) {
            contentBuilder()
        }
        self.init(publisher: publisher, components: components)
    }
}


public extension Component {

    // This should only be called from within the resultBuilder closure of OneOf.init.
    init<T>(with transform: @escaping (Output) -> T?, view viewBuilder: (AnyPublisher<T, Never>) -> UIView) {
        let publisher = OneOfComponentsBuilder.currentPublisher(for: Output.self)
            .compactMap(transform)
            .eraseToAnyPublisher()

        self.init(
            predicate: { transform($0) != nil },
            view: viewBuilder(publisher)
        )
    }

    init(for predicate: @escaping (Output) -> Bool, view viewBuilder: () -> UIView) {
        self.init(predicate: predicate, view: viewBuilder())
    }

    static func `default`(viewBuilder: () -> UIView) -> Self {
        let view = viewBuilder()
        return self.init(predicate: { _ in true }, view: view)
    }

    static func `default`(viewBuilder: (AnyPublisher<Output, Never>) -> UIView) -> Self {
        let publisher = OneOfComponentsBuilder.currentPublisher(for: Output.self)
        let view = viewBuilder(publisher)
        return self.init(predicate: { _ in true }, view: view)
    }
}

public extension Component where Output: Equatable {

    init(for value: Output, view viewBuilder: () -> UIView) {
        let predicate = { $0 == value }
        self.init(predicate: predicate, view: viewBuilder())
    }
}


@resultBuilder
public struct OneOfComponentsBuilder {

    public static func buildBlock<T>(_ components: Component<T>...) -> [Component<T>] {
        components
    }
}


private extension OneOfComponentsBuilder {

    private static var publisherStack = [Any]()

    static func currentPublisher<T>(for: T.Type) -> AnyPublisher<T, Never> {
        guard let object = publisherStack.last else {
            preconditionFailure("Publisher stack is empty. Programming error")
        }
        guard let publisher = object as? AnyPublisher<T, Never> else {
            preconditionFailure("Publisher is of unexpected type")
        }
        return publisher
    }

    static func with<Output, T>(_ publisher: some Publisher<Output, Never>, work: () -> T) -> T {
        publisherStack.append(publisher)
        let result = work()
        _ = publisherStack.removeLast()
        return result
    }
}
