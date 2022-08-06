import Foundation
import Combine


public extension SomeView {

    func onChange<A: ViewIsAvailableProvider, V, P: Publisher>(of publisherParameter: ValueParameter<A, Self, P>, perform action: @escaping (Self, A, V) -> Void) -> Self where P.Output == V, P.Failure == Never {
        publisherParameter.context = self
        publisherParameter.invalidationHandler = { [weak publisherParameter] in
            guard let root = publisherParameter?.root else { return }
            guard let identifier = publisherParameter?.identifier else { return }
            root.removeViewIsAvailableHandler(forIdentifier: identifier)
        }

        publisherParameter.root?.addViewIsAvailableHandler(withIdentifier: publisherParameter.identifier) {
            guard let publisher = publisherParameter.makeValue() else {
                return nil
            }
            return publisher.sink { value in
                guard
                    let context = publisherParameter.context,
                    let root = publisherParameter.root
                else {
                    return
                }
                action(context, root, value)
            }
        }
        return self
    }
}
