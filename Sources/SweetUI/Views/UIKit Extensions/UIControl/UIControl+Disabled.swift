import Foundation


public extension UIControl {
    
    func disabled(_ value: Bool) -> Self {
        self.enabled(!value)
    }
    
    func disabled(_ publisher: some Publisher<Bool, Never>) -> Self {
        return enabled(publisher.inverted)
    }
}
