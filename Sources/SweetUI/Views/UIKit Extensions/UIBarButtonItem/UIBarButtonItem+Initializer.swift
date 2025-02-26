import UIKit
import Combine


// MARK: - systemItem based init

@available(iOS 14, *)
public extension UIBarButtonItem {
    
    convenience init(systemItem: UIBarButtonItem.SystemItem, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping (Self) -> Void) {
        let action = UIAction { handler(($0.sender as? Self)!) }
        self.init(systemItem: systemItem, primaryAction: action, menu: nil)
        self.style = style
    }
    
    convenience init(systemItem: UIBarButtonItem.SystemItem, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping () -> Void) {
        let action = UIAction { _ in handler() }
        self.init(systemItem: systemItem, primaryAction: action, menu: nil)
        self.style = style
    }
    
    convenience init(systemItem: UIBarButtonItem.SystemItem, style: UIBarButtonItem.Style = .plain, menu: UIMenu) {
        self.init(systemItem: systemItem, primaryAction: nil, menu: menu)
        self.style = style
    }
    
    convenience init(systemItem: UIBarButtonItem.SystemItem, style: UIBarButtonItem.Style = .plain) {
        self.init(systemItem: systemItem, primaryAction: nil, menu: nil)
        self.style = style
    }
}


// MARK: - Title + image based init

@available(iOS 14, *)
public extension UIBarButtonItem {
    
    // # image:
    
    convenience init(title: String? = nil, image: UIImage? = nil, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping (Self) -> Void) {
        let action = UIAction { handler(($0.sender as? Self)!) }
        if let title { action.title = title }
        if let image { action.image = image }
        self.init(title: title, image: image, primaryAction: action)
        self.style = style
    }
    
    convenience init(title: String? = nil, image: UIImage? = nil, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping () -> Void) {
        let action = UIAction { _ in handler() }
        if let title { action.title = title }
        if let image { action.image = image }
        self.init(title: title, image: image, primaryAction: action)
        self.style = style
    }
    
    convenience init(title: String? = nil, image: UIImage? = nil, style: UIBarButtonItem.Style = .plain, menu: UIMenu) {
        self.init(title: title, image: image, primaryAction: nil, menu: menu)
        self.style = style
    }
    
    convenience init(title: String? = nil, image: UIImage? = nil, style: UIBarButtonItem.Style = .plain) {
        self.init(title: title, image: image, primaryAction: nil, menu: nil)
        self.style = style
    }
    
    
    // # imageName:
    
    convenience init(title: String? = nil, imageName: String, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping (Self) -> Void) {
        let image = UIImage(named: imageName)
        let action = UIAction { handler(($0.sender as? Self)!) }
        if let title { action.title = title }
        if let image { action.image = image }
        self.init(title: title, image: image, primaryAction: action)
        self.style = style
    }
    
    convenience init(title: String? = nil, imageName: String, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping () -> Void) {
        let image = UIImage(named: imageName)
        let action = UIAction { _ in handler() }
        if let title { action.title = title }
        if let image { action.image = image }
        self.init(title: title, image: image, primaryAction: action)
        self.style = style
    }
    
    convenience init(title: String? = nil, imageName: String, style: UIBarButtonItem.Style = .plain, menu: UIMenu) {
        let image = UIImage(named: imageName)
        self.init(title: title, image: image, primaryAction: nil, menu: menu)
        self.style = style
    }
    
    convenience init(title: String? = nil, imageName: String, style: UIBarButtonItem.Style = .plain) {
        let image = UIImage(named: imageName)
        self.init(title: title, image: image, primaryAction: nil, menu: nil)
        self.style = style
    }
    
    
    // # systemImageName:
    
    convenience init(title: String? = nil, systemImageName: String, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping (Self) -> Void) {
        let image = UIImage(systemName: systemImageName)
        let action = UIAction { handler(($0.sender as? Self)!) }
        if let title { action.title = title }
        if let image { action.image = image }
        self.init(title: title, image: image, primaryAction: action)
        self.style = style
    }
    
    convenience init(title: String? = nil, systemImageName: String, style: UIBarButtonItem.Style = .plain, action handler: @MainActor @escaping () -> Void) {
        let image = UIImage(systemName: systemImageName)
        let action = UIAction { _ in handler() }
        if let title { action.title = title }
        if let image { action.image = image }
        self.init(title: title, image: image, primaryAction: action)
        self.style = style
    }
    
    convenience init(title: String? = nil, systemImageName: String, style: UIBarButtonItem.Style = .plain, menu: UIMenu) {
        let image = UIImage(systemName: systemImageName)
        self.init(title: title, image: image, primaryAction: nil, menu: menu)
        self.style = style
    }
    
    convenience init(title: String? = nil, systemImageName: String, style: UIBarButtonItem.Style = .plain) {
        let image = UIImage(systemName: systemImageName)
        self.init(title: title, image: image, primaryAction: nil, menu: nil)
        self.style = style
    }
}


// MARK: - CustomView

public extension UIBarButtonItem {
    
    convenience init(customView builder: () -> UIView) {
        let customView = builder()
        self.init(customView: customView)
    }
}


// MARK: - isSelected

@available(iOS 15, *)
public extension UIBarButtonItem {
    
    // MARK: Types
    
    private class BarButtonItemIsSelectedToggler: NSObject {
        
        static let shared = BarButtonItemIsSelectedToggler()
        
        private let subjectsByItem = NSMapTable<UIBarButtonItem, AnySubject<Bool, Never>>.weakToStrongObjects()
        
        func registerSubject(_ subject: some Subject<Bool, Never>, for item: UIBarButtonItem) {
            item.target = self
            item.action = #selector(BarButtonItemIsSelectedToggler.toggle(_:))
            let anySubject = subject.eraseToAnySubject()
            subjectsByItem.setObject(anySubject, forKey: item)
        }
        
        private func subject(for item: UIBarButtonItem) -> AnySubject<Bool, Never>? {
            subjectsByItem.object(forKey: item)
        }
        
        @objc
        func toggle(_ sender: AnyObject) {
            guard let barButtonItem = sender as? UIBarButtonItem else { return }
            let subject = subject(for: barButtonItem)
            subject?.send(!barButtonItem.isSelected)
        }
    }
    
    // # image:
    
    convenience init(
        title: String? = nil,
        image: UIImage,
        style: UIBarButtonItem.Style = .plain,
        selected subject: some Subject<Bool, Never>
    ) {
        self.init(title: title, image: image, primaryAction: nil)
        self.style = style
        
        BarButtonItemIsSelectedToggler.shared.registerSubject(subject, for: self)
        subject.sink { [weak self] newValue in
            self?.isSelected = newValue
        }
        .store(in: .current)
    }
    
    
    // # imageName:
    
    convenience init(
        title: String? = nil,
        imageName: String,
        style: UIBarButtonItem.Style = .plain,
        selected subject: some Subject<Bool, Never>
    ) {
        let image = UIImage(named: imageName)
        self.init(title: title, image: image, primaryAction: nil)
        self.style = style
        
        BarButtonItemIsSelectedToggler.shared.registerSubject(subject, for: self)
        subject.sink { [weak self] newValue in
            self?.isSelected = newValue
        }
        .store(in: .current)
        
    }
    
    
    // # systemImageName:
    
    convenience init(
        title: String? = nil,
        systemImageName: String,
        style: UIBarButtonItem.Style = .plain,
        selected subject: some Subject<Bool, Never>
    ) {
        let image = UIImage(systemName: systemImageName)
        self.init(title: title, image: image, primaryAction: nil)
        self.style = style
        
        BarButtonItemIsSelectedToggler.shared.registerSubject(subject, for: self)
        subject.sink { [weak self] newValue in
            self?.isSelected = newValue
        }
        .store(in: .current)        
    }
}
