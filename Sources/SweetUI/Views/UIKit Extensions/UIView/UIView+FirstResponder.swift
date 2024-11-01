import UIKit
import Combine

public typealias FirstResponderState<T: Hashable> = Binding<T>


public extension UIView {
    
    func becomesFirstResponder<F: Hashable>(
        when publisher: FirstResponderState<F>,
        isEqualTo targetValue: F
    ) -> Self {
        return becomesFirstResponder(when: publisher.map { $0 == targetValue })
    }
    
    func becomesFirstResponder<P: Publisher>(
        when publisher: P
    ) -> Self where P.Output == Bool, P.Failure == Never {
        publisher.sink { [weak self] isFirstResponder in
            guard isFirstResponder,
                  let self else { return }
            self.becomeFirstResponder()
        }
        .store(in: .current)
        return self
    }
}
