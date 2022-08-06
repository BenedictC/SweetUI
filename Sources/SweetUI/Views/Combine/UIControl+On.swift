import Combine
import UIKit


//  MARK: - On Event

public extension SomeView where Self: UIControl {

    func on<A: ViewIsAvailableProvider>(_ event: UIControl.Event, perform actionParameter: ActionParameter<A, Self, UIControl.Event>) -> Self {
        actionParameter.context = self
        actionParameter.invalidationHandler = { [weak actionParameter] in
            guard let root = actionParameter?.root else { return }
            guard let identifier = actionParameter?.identifier else { return }
            root.removeViewIsAvailableHandler(forIdentifier: identifier)
        }
        actionParameter.root?.addViewIsAvailableHandler(withIdentifier: actionParameter.identifier) {
            guard let context = actionParameter.context else { return nil }

            return context.addAction(for: event, with: { [weak actionParameter] _, event in
                actionParameter?.execute(with: event)
            })
        }
        return self
    }
}
