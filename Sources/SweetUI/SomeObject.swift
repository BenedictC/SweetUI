import Foundation


public protocol SomeObject: AnyObject { 
    
}


// MARK: - Configure

public extension SomeObject {

    func configure(using closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}


// MARK: - Default conformance

// This isn't pretty, because we're polluting a large number of classes, but it is useful.
extension NSObject: SomeObject { }


