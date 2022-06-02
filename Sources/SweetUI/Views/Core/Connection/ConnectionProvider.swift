// MARK: - ConnectionProvider

public protocol ConnectionProvider: AnyObject {

    typealias ConnectionHandler = () -> Any

    func addConnectionHandler(withIdentifier identifier: AnyHashable, _ handler: @escaping ConnectionHandler)
    func removeConnectionHandler(forIdentifier identifier: AnyHashable)
}


// MARK: - ViewConnectionProvider

public protocol ViewConnectionProvider: ConnectionProvider {

}


// MARK: - ViewModelConnectionProvider

public protocol ViewModelConnectionProvider: ViewConnectionProvider {

    associatedtype ViewModel = Void

    var viewModel: ViewModel? { get }
}
