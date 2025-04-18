import Foundation
import UIKit


// MARK: - Core

public typealias LayoutView = _LayoutView & LayoutProviding


public protocol LayoutProviding: _LayoutProviding, ViewBodyProvider {

    associatedtype Configuration = Void
    var configuration: Configuration { get }

    associatedtype Content: UIView = UIView
    var content: Content { get }
}


// MARK:  - Implementation details

public protocol _LayoutProviding: _ViewBodyProvider {

    var _configuration: Any! { get }
    var _content: Any! { get }
}


public extension LayoutProviding {

    var configuration: Configuration { _configuration as! Configuration }
    var content: Content { _content as! Content }
}


open class _LayoutView: UIView {

    // MARK: Properties

    public fileprivate(set) var _content: Any!
    public fileprivate(set) var _configuration: Any!
    fileprivate lazy var defaultCancellableStorage = CancellableStorage()


    // MARK: Instance life cycle

    public required init(anyConfiguration: Any?, anyContent: Any?) {
        // TODO: It's not ideal that the public init contains Any? instead of the proper type.
        super.init(frame: .zero)
        self._configuration = anyConfiguration
        self._content = anyContent
        guard let host = self as? _ViewBodyProvider else {
            preconditionFailure("_LayoutView subclasses must conform to _ViewBodyProvider")
        }
        host.storeCancellables(with: View.CancellableKey.awake) {
            host.awake()
        }
        host.storeCancellables(with: View.CancellableKey.loadBody) {
            host.initializeBodyHosting()
        }
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - CancellableStorageProvider defaults

extension CancellableStorageProvider where Self: _LayoutView {

    public var cancellableStorage: CancellableStorage { defaultCancellableStorage }
}



// MARK: - Typed init

public extension LayoutProviding where Self: _LayoutView {

    init(configuration: Configuration, content: Content) {
        self.init(anyConfiguration: configuration, anyContent: content)
    }

    init(configuration: Configuration, _ content: Content) {
        self.init(configuration: configuration, content: content)
    }
}


public extension LayoutProviding where Self: _LayoutView, Configuration: Defaultable {

    init(content: Content) {
        self.init(configuration: Configuration.default, content: content)
    }

    init(_ content: Content) {
        self.init(configuration: .default, content: content)
    }
}


public extension LayoutProviding where Self: _LayoutView, Self.Configuration == Void {

    @available(*, unavailable)
    init(configuration: Configuration, content: Content) {
        self.init(configuration: configuration, content: content)
    }

    @available(*, unavailable)
    init(configuration: Configuration, _ content: Content) {
        self.init(configuration: configuration, content: content)
    }

    init(content: Content) {
        self.init(configuration: (), content: content)
    }

    init(_ content: Content) {
        self.init(configuration: (), content: content)
    }
}


// MARK: - ResultBuilder

public extension LayoutProviding where Self: _LayoutView {

    init(configuration: Configuration, @LayoutBuilder<Content> contentBuilder: () -> Content) {
        self.init(configuration: configuration, content: contentBuilder())
    }
}

public extension LayoutProviding where Self: _LayoutView, Self.Configuration: Defaultable {

    init(@LayoutBuilder<Content> contentBuilder: () -> Content) {
        let configuration = Configuration.default
        self.init(configuration: configuration, content: contentBuilder())
    }
}

public extension LayoutProviding where Self: _LayoutView, Self.Configuration == Void {

    @available(*, unavailable)
    init(configuration: Configuration, @LayoutBuilder<Content> contentBuilder: () -> Content) {
        self.init(configuration: configuration, content: contentBuilder())
    }

    init(@LayoutBuilder<Content> contentBuilder: () -> Content) {
        self.init(configuration: (), content: contentBuilder())
    }
}


@resultBuilder
public struct LayoutBuilder<ArrangeViews> {

    public static func buildBlock<V1>(_ v1: V1) -> V1 {
        return v1
    }

    public static func buildBlock<V1, V2>(_ v1: V1, _ v2: V2) -> (V1, V2) {
        return (v1, v2)
    }

    public static func buildBlock<V1, V2, V3>(_ v1: V1, _ v2: V2, _ v3: V3) -> (V1, V2, V3) {
        return (v1, v2, v3)
    }

    public static func buildBlock<V1, V2, V3, V4>(_ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4) -> (V1, V2, V3, V4) {
        return (v1, v2, v3, v4)
    }

    public static func buildBlock<V1, V2, V3, V4, V5>(_ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5) -> (V1, V2, V3, V4, V5) {
        return (v1, v2, v3, v4, v5)
    }

    public static func buildBlock<V1, V2, V3, V4, V5, V6>(_ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6) -> (V1, V2, V3, V4, V5, V6) {
        return (v1, v2, v3, v4, v5, v6)
    }

    public static func buildBlock<V1, V2, V3, V4, V5, V6, V7>(_ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7) -> (V1, V2, V3, V4, V5, V6, V7) {
        return (v1, v2, v3, v4, v5, v6, v7)
    }

    public static func buildBlock<V1, V2, V3, V4, V5, V6, V7, V8>(_ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8) -> (V1, V2, V3, V4, V5, V6, V7, V8) {
        return (v1, v2, v3, v4, v5, v6, v7, v8)
    }

    public static func buildBlock<V1, V2, V3, V4, V5, V6, V7, V8, V9>(_ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9) -> (V1, V2, V3, V4, V5, V6, V7, V8, V9) {
        return (v1, v2, v3, v4, v5, v6, v7, v8, v9)
    }

    public static func buildBlock<V1, V2, V3, V4, V5, V6, V7, V8, V9, V10>(_ v1: V1, _ v2: V2, _ v3: V3, _ v4: V4, _ v5: V5, _ v6: V6, _ v7: V7, _ v8: V8, _ v9: V9, _ v10: V10) -> (V1, V2, V3, V4, V5, V6, V7, V8, V9, V10) {
        return (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10)
    }
}
