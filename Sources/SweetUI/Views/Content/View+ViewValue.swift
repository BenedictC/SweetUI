import Foundation
import UIKit
import Combine


// MARK: - ViewValue

public protocol ViewValueSubject: Subject where Failure == Never {
    var value: Output { get }
    init(_ initialValue: Output)
}

extension CurrentValueSubject: ViewValueSubject where Failure == Never { }

public typealias ViewValue<T> = CurrentValueSubject<T, Never>



// MARK: - View + ViewValue initialization

public extension _View where ViewModel: ViewValueSubject {

    typealias Value = ViewModel.Output

    var value: Value {
        get { return viewModel.value }
        set { viewModel.send(newValue) }
    }

    convenience init(initialValue: Value) {
        let subject = ViewModel(initialValue)
        self.init(viewModel: subject)
        self.anyViewModel = subject // It's safe to retain subject because we know it won't create a retain cycle
    }

    convenience init(initialValue: Value = .default) where Value: Defaultable {
        let subject = ViewModel(initialValue)
        self.init(viewModel: subject)
        self.anyViewModel = subject // It's safe to retain subject because we know it won't create a retain cycle
    }
}


// MARK: - View + ViewValue publishers

public extension ViewModelProvider where ViewModel: ViewValueSubject {

    var valuePublisher: ViewState<ViewModel.Output> { viewModel.eraseToAnyPublisher() }
}


// MARK: - View + ViewValue publishers for optional types

public protocol _Optionable {
    associatedtype Wrapped
}

extension Optional: _Optionable { }

private extension _Optionable {

    var asOptional: Wrapped? {
        guard let asOptional = self as? Optional<Wrapped> else { return nil }
        return asOptional
    }
}
