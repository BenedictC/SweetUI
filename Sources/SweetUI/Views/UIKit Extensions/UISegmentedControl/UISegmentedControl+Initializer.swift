import Foundation
import UIKit


public extension UISegmentedControl {

    convenience init<S: Sequence>(segmentTitles: () -> S) where S.Element == String? {
        self.init(frame: .zero)
        for title in segmentTitles().reversed() {
            self.insertSegment(withTitle: title, at: 0, animated: false)
        }
    }

    convenience init<S: Sequence>(segmentImages: () -> S) where S.Element == UIImage? {
        self.init(frame: .zero)
        for image in segmentImages().reversed() {
            self.insertSegment(with: image, at: 0, animated: false)
        }
    }
}


@available(iOS 14.0, *)
public extension UISegmentedControl {

    convenience init<S: Sequence>(segmentActions: () -> S) where S.Element == UIAction {
        self.init(frame: .zero)
        for action in segmentActions().reversed() {
            self.insertSegment(action: action, at: 0, animated: false)
        }
    }
}
