import Combine


@resultBuilder
public struct CancellablesBuilder {

    public static func buildBlock(_ components: (any Cancellable)?...) -> AnyCancellable {
        let cancellables = components.compactMap { $0 }
        return AnyCancellable {
            cancellables.forEach { $0.cancel() }
        }
    }
}
