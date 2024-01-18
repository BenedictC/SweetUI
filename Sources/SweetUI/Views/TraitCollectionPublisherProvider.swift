import UIKit
import Combine


public typealias PublishedTraitCollection = (previous: UITraitCollection?, current: UITraitCollection)


public protocol TraitCollectionPublisherProvider: AnyObject {

    var traitCollectionPublisher: AnyPublisher<PublishedTraitCollection, Never> { get }
}


// MARK: - Implementation

public protocol _TraitCollectionPublisherProviderImplementation: TraitCollectionPublisherProvider {
    var _traitCollectionPublisherController: TraitCollectionPublisherController { get }
}


public extension _TraitCollectionPublisherProviderImplementation {

    var traitCollectionPublisher: AnyPublisher<PublishedTraitCollection, Never> { _traitCollectionPublisherController.traitCollectionPublisher }
}


public class TraitCollectionPublisherController {

    private let subject: CurrentValueSubject<PublishedTraitCollection, Never>
    var traitCollectionPublisher: AnyPublisher<PublishedTraitCollection, Never> { subject.eraseToAnyPublisher() }

    init(initialTraitCollection: UITraitCollection) {
        self.subject = CurrentValueSubject((nil, initialTraitCollection))
    }

    func send(previous: UITraitCollection?, current: UITraitCollection) {
        subject.send((previous, current))
    }
}
