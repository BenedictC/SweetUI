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


// MARK: - Subscribable

@propertyWrapper
public struct Subscribable<T: AnyObject> {

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
public class SubscribableProxy<Source: AnyObject> {

    var source: Source
    var cancellables = Set<AnyCancellable>()
    var anyPublishersByKeyPaths = [AnyHashable: Any]()

    init(source: Source) {
        self.source = source
    }


    // Published values

    public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Source, T>) -> AnyPublisher<T, Never>? {
        set {
            let isUnseenKeyPath = anyPublishersByKeyPaths[keyPath] == nil
            guard isUnseenKeyPath else {
                print("⚠️ Attempted to set a publisher more than once while building barItems. Only the first publisher is stored. Subsequent publishers are ignored.")
                return
            }
            guard let newValue else {
                // Nothing to do
                return
            }
            anyPublishersByKeyPaths[keyPath] = newValue
            let contentController = BarItemContentController.controller(for: Source.self)
            newValue.sink { [weak source] value in
                guard let source else { return }
                contentController.setValue(value: value, for: keyPath, of: source)
            }
            .store(in: &cancellables)
        }

        get {
            let any = anyPublishersByKeyPaths[keyPath]
            return any as? AnyPublisher<T, Never>
        }
    }
}


final class BarItemContentController {

    private static let `default` = BarItemContentController()
    private static let controllersByClass = NSMapTable<AnyObject, BarItemContentController>.strongToStrongObjects()

    var settersByKeyPath =  [AnyHashable: Any]()

    static func controller<T: AnyObject>(for classType: T.Type) -> BarItemContentController {
        var optionalClassType: AnyClass? = classType
        while let classType = optionalClassType {
            if let existing = controllersByClass.object(forKey: classType) {
                return existing
            }
            optionalClassType = class_getSuperclass(classType)
        }
        return Self.default
    }

    func setValue<Root, Value>(value: Value, for keyPath: ReferenceWritableKeyPath<Root, Value>, of source: Root) {
        if let setter = settersByKeyPath[keyPath] as? (Value, Root) -> Void {
            setter(value, source)
            return
        }
        source[keyPath: keyPath] = value
    }
}
