import UIKit
import Combine


//    @property (nonatomic, readwrite, assign) UIBarButtonItemStyle style;            // default is UIBarButtonItemStylePlain
//    @property (nonatomic, readwrite, copy  , nullable) NSSet<NSString *>   *possibleTitles;   // default is nil
//    @property (nonatomic, readwrite, strong, nullable) __kindof UIView     *customView;       // default is nil
//    /// Set the primaryAction on this item, updating the title & image of the item if appropriate (primaryAction is non-nil, and this is not a system item). When primaryAction is non-nil, the target & action properties are ignored. If primaryAction is set to nil, the title & image properties are left unchanged.
//    @property (nonatomic, readwrite, copy, nullable) UIAction *primaryAction API_AVAILABLE(ios(14.0));
//    /// Preferred menu element ordering strategy for menus displayed by this button.
//    @property (nonatomic) UIContextMenuConfigurationElementOrder preferredMenuElementOrder API_AVAILABLE(ios(16.0), tvos(17.0)) API_UNAVAILABLE(watchos);
//    /// Indicates if the button changes selection as its primary action.
//    /// This shows the menu as options for selection if a menu is populated and no action when tapped is enabled.
//    /// If no menu is provided and no action is enabled when tapped, the item is toggled on and off for the primary action.
//    @property (nonatomic, readwrite, assign) BOOL changesSelectionAsPrimaryAction API_AVAILABLE(ios(15.0), tvos(17.0)) API_UNAVAILABLE(watchos);
//    /// Whether or not symbol animations are enabled for this bar button item.
//    @property (nonatomic, readwrite, assign, getter=isSymbolAnimationEnabled) BOOL symbolAnimationEnabled API_AVAILABLE(ios(17.0), tvos(17.0), watchos(10.0));
//    /// A UIMenuElement that should substitute for the UIBarButtonItem when displayed in a menu.
//    @property (nonatomic, readwrite, copy, nullable) UIMenuElement *menuRepresentation API_AVAILABLE(ios(16.0)) API_UNAVAILABLE(tvos, watchos);


public extension UIBarButtonItem {
    
    func width(_ value: CGFloat) -> Self {
        width = value
        return self
    }
    
    func width(_ publisher: some Publisher<CGFloat, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.width = value
        }
        .store(in: .current)
        return self
    }
}


@available(iOS 14, *)
public extension UIBarButtonItem {
    
    func menu(_ value: UIMenu?) -> Self {
        menu = value
        title = menu?.title
        image = menu?.image
        return self
    }
    
    func menu(_ publisher: some Publisher<UIMenu?, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            _ = self?.menu(value)
        }
        .store(in: .current)
        return self
    }
}


@available(iOS 15, *)
public extension UIBarButtonItem {
    
    func selected(_ value: Bool) -> Self {
        isSelected = value
        return self
    }
    
    func selected(_ publisher: some Publisher<Bool, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.isSelected = value
        }
        .store(in: .current)        
        return self
    }
}


@available(iOS 16, *)
public extension UIBarButtonItem {
    
    func hidden(_ value: Bool) -> Self {
        isHidden = value
        return self
    }
    
    func hidden(_ publisher: some Publisher<Bool, Never>) -> Self {
        // HACK ALERT! This causes a runtime crash due to a compiler bug related to the keyPath:
        // assign(to: \.isHidden, from: publisher, cancellableStorageProvider: cancellableStorageProvider)
        // So we have to do it the long way:
        publisher.sink { [weak self] value in
            self?.isHidden = value
        }
        .store(in: .current)        
        return self
    }
}
