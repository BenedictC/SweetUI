import Combine


public protocol ViewModelProvider {

    associatedtype ViewModel = Void

    var viewModel: ViewModel! { get }

}


// MARK: - ViewValue

public protocol ViewValueSubject: Subject where Failure == Never {
    var value: Output { get }
    init(_ initialValue: Output)
}


// MARK: Implementation

extension CurrentValueSubject: ViewValueSubject where Failure == Never { }

public typealias ViewValue<T> = CurrentValueSubject<T, Never>



// MARK: - ViewValue accessors

public extension ViewModelProvider where Self: AnyObject, ViewModel: ViewValueSubject {

    typealias Value = ViewModel.Output

    var value: Value {
        get { return viewModel.value }
        set { viewModel.send(newValue) }
    }

    var valuePublisher: ViewState<Value> { viewModel.eraseToAnyPublisher() }
}
