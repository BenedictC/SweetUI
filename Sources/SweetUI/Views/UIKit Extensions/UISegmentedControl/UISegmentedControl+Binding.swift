import Foundation
import UIKit
import Combine


public extension UISegmentedControl {
    
    // TODO: Should this take a subject instead of a publisher?
    func selectedSegmentIndex<P: Publisher>(
        _ publisher: P
    ) -> Self where P.Output == Int, P.Failure == Never {
        publisher.sink { [weak self] index in
            guard let self else { return }
            guard self.selectedSegmentIndex != index else { return }
            guard (-1..<(self.numberOfSegments)).contains(index) else {
                print("Published value '\(index)' is out of range for selectedSegmentIndex of '\(self)'.")
                return
            }
            self.selectedSegmentIndex = index
        }
        .store(in: CancellableStorage.current)
        return self
    }
    
    // TODO: Should this take a subject instead of a publisher?
    func selectedSegmentIndex<P: Publisher>(
        _ initialPublisher: P
    ) -> Self where P.Output == Int?, P.Failure == Never {
        let publisher = initialPublisher.map { $0 ?? UISegmentedControl.noSegment }
        return selectedSegmentIndex(publisher)
    }
    
    //    func selectedSegmentIndex<S: Subject>(
    //        _ subject: S,
    //        cancellableStorageProvider optionalCancellableStorageProvider: CancellableStorageProvider? = nil
    //    ) -> Self where S.Output == Int, S.Failure == Never {
    //        let cancellable = SelectedSegmentIndexReceiver.shared.bindIndexSelection(of: self, to: subject)
    //        let cancellableStorageProvider = CancellableStorage.current
    //        cancellableStorageProvider.storeCancellable(cancellable, self)
    //        return self
    //    }
}


private class SelectedSegmentIndexReceiver {
    
    static let shared = SelectedSegmentIndexReceiver()
    
    private var subjectsByControl = NSMapTable<UISegmentedControl, NSMutableSet>.weakToStrongObjects()
    
    private func subjects(for control: UISegmentedControl) -> NSMutableSet {
        if let existing = subjectsByControl.object(forKey: control) {
            return existing
        }
        let subjects = NSMutableSet()
        subjectsByControl.setObject(subjects, forKey: control)
        return subjects
    }
    
    func bindIndexSelection<S: Subject>(of control: UISegmentedControl, to subject: S) -> AnyCancellable where S.Output == Int, S.Failure == Never {
        let anySubject = subject.eraseToAnySubject()
        // Store the subject
        subjects(for: control).add(anySubject)
        
        // Add the target
        control.addTarget(self, action: #selector(sendSelectedSegmentIndex(_:)), for: .valueChanged)
        let sendCancellable = AnyCancellable {
            control.removeTarget(self, action: #selector(self.sendSelectedSegmentIndex(_:)), for: .valueChanged)
        }
        // Receive values from subject
        let receiveCancellable = subject.sink { [weak control] index in
            guard let control else { return }
            guard control.selectedSegmentIndex != index else { return }
            guard (-1..<(control.numberOfSegments)).contains(index) else {
                print("Published value '\(index)' is out of range for selectedSegmentIndex of '\(control)'.")
                return
            }
            control.selectedSegmentIndex = index
        }
        
        return AnyCancellable {
            [sendCancellable, receiveCancellable].forEach { $0.cancel() }
        }
    }
    
    @objc
    private func sendSelectedSegmentIndex(_ sender: Any?) {
        guard let control = sender as? UISegmentedControl else {
            return
        }
        let newValue = control.selectedSegmentIndex
        subjects(for: control)
            .compactMap { $0 as? AnySubject<Int, Never> }
            .forEach { $0.send(newValue) }
    }
}
