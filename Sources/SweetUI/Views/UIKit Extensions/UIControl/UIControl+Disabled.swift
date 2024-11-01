import Foundation


public extension UIControl {
    
    func disabled(_ value: Bool) -> Self {
        self.enabled(!value)
    }
    
    func disabled<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == Bool, P.Failure == Never {
        return enabled(publisher.inverted)
    }
}
