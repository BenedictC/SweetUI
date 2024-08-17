import UIKit
import Combine


public typealias TraitCollectionChanges = (previous: UITraitCollection?, current: UITraitCollection)


public protocol TraitCollectionChangesProvider: AnyObject {

    var traitCollectionChanges: AnyPublisher<TraitCollectionChanges, Never> { get }
}


// MARK: - TraitCollectionChangesController (Internal implementation helper)

class TraitCollectionChangesController {

    private let subject: CurrentValueSubject<TraitCollectionChanges, Never>
    var traitCollectionChanges: AnyPublisher<TraitCollectionChanges, Never> { subject.eraseToAnyPublisher() }

    init(initialTraitCollection: UITraitCollection) {
        self.subject = CurrentValueSubject((nil, initialTraitCollection))
    }

    func send(previous: UITraitCollection?, current: UITraitCollection) {
        subject.send((previous, current))
    }
}
