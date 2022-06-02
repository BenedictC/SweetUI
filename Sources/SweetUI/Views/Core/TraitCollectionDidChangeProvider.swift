import UIKit


public protocol TraitCollectionDidChangeProvider: AnyObject {

    func addTraitCollectionDidChangeHandler(_ handler: @escaping (_ previous: UITraitCollection?, _ current: UITraitCollection) -> Bool)
}
