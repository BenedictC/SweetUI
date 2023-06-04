import UIKit
import Combine


public extension ViewControllerRequirements {

    var barItems: BarItems { BarItems(cancellables: []) }

    func makeBarItems(configuration: (BarItemsBuilder<Self>) -> Void) -> BarItems {
        let builder = BarItemsBuilder(viewController: self)
        let barItems = builder.build(using: configuration)
        return barItems
    }
}


// MARK: -

public struct BarItems {
    internal var cancellables = Set<AnyCancellable>()
}


public class BarItemsBuilder<VC: UIViewController> {

    @Subscribable public private(set) var viewController: VC
    @Subscribable public private(set) var navigationItem: UINavigationItem
    @Subscribable public private(set) var tabBarItem: UITabBarItem

    init(viewController: VC) {
        self.viewController = viewController
        self.navigationItem = viewController.navigationItem
        self.tabBarItem = viewController.tabBarItem
    }

    func build(using configuration: (BarItemsBuilder<VC>) -> Void) -> BarItems {
        configuration(self)
        var cancellables = Set<AnyCancellable>()
        cancellables.formUnion($viewController.cancellables)
        cancellables.formUnion($navigationItem.cancellables)
        cancellables.formUnion($tabBarItem.cancellables)
        return BarItems(cancellables: cancellables)
    }
}


// MARK: -

@propertyWrapper
public struct Subscribable<T> {

    public var wrappedValue: T {
        get { projectedValue.source }
        set { projectedValue.source = newValue }
    }

    public var projectedValue: SubscribableProxy<T>

    public init(wrappedValue: T) {
        self.projectedValue = SubscribableProxy(source: wrappedValue)
    }
}


// MARK: - SubscribingProxy

@dynamicMemberLookup
public class SubscribableProxy<Source> {

    var source: Source
    var cancellables = Set<AnyCancellable>()
    var storedKeyPaths = Set<AnyHashable>()

    init(source: Source) {
        self.source = source
    }

//    // Plain values
//    public subscript<T>(dynamicMember member: ReferenceWritableKeyPath<Source, T>) -> T {
//        set { source[keyPath: member] = newValue }
//        get { source[keyPath: member] }
//    }

    // Published values
    public subscript<T, P: Publisher>(dynamicMember member: ReferenceWritableKeyPath<Source, T>) -> P where P.Output == T, P.Failure == Never {
        set {
            if storedKeyPaths.contains(member) {
                print("⚠️ Attempted to set a publisher more than once during barItem building. Only the first publisher is stored. Subsequent publishers are ignored.")
                return
            }
            storedKeyPaths.formUnion([member])

            let source = self.source
            newValue.sink {
                source[keyPath: member] = $0
            }
            .store(in: &cancellables)
        }
        @available(*, unavailable, message: "Publishers cannot be read.")
        get {
            fatalError()
        }
    }
}
