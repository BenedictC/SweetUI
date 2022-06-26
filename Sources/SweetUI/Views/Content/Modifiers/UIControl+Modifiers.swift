import UIKit


// MARK: - Actions

public extension UIControl {

    func on(_ event: UIControl.Event, send action: Selector, to target: Any? = nil) -> Self {
        self.addTarget(target, action: action, for: event)
        return self
    }

    @available(iOS 14.0, *)
    func on(_ event: UIControl.Event, perform action: UIAction) -> Self {
        self.addAction(action, for: event)
        return self
    }
}


// MARK: - Modifiers

public extension UIControl {

    func enabled(_ value: Bool) -> Self {
        self.isEnabled = value
        return self
    }

    func selected(_ value: Bool) -> Self {
        self.isSelected = value
        return self
    }

    func highlighted(_ value: Bool) -> Self {
        self.isHighlighted = value
        return self
    }

    func contentVerticalAlignment(_ value: UIControl.ContentVerticalAlignment) -> Self {
        self.contentVerticalAlignment = value
        return self
    }

    func contentHorizontalAlignment(_ value: UIControl.ContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = value
        return self
    }

    @available(iOS 14.0, *)
    func contextMenuInteractionEnabled(_ value: Bool) -> Self {
        self.isContextMenuInteractionEnabled = value
        return self
    }

    @available(iOS 14.0, *)
    func showsMenuAsPrimaryAction(_ value: Bool) -> Self {
        self.showsMenuAsPrimaryAction = value
        return self
    }

    @available(iOS 15.0, *)
    func toolTip(_ value: String) -> Self {
        self.toolTip = value
        return self
    }
}
