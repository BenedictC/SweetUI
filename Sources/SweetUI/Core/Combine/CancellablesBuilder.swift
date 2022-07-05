import Combine


@resultBuilder
public struct CancellablesBuilder {

    public static func buildBlock(_ components: Any...) -> AnyCancellable {
        let cancellables = components.compactMap { component -> Cancellable? in
            if let component = component as? Cancellable {
                return component
            }
            if component is Void {
                return nil
            }
            print("Unexpected value in CancellablesBuilder. Expects Cancellables or Void, received value of type \(type(of: component)): \(component)")
            return nil
        }
        return AnyCancellable {
            cancellables.forEach { $0.cancel() }
        }
    }
}
