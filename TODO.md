# TODO

- Bindings and inits for:
    - UISlider.value // Copy and paste of textField.text binding
    - UIStepper.value // Copy and paste of textField.text binding

- Remaining UIKit modifiers
    - GestureRecognizers
    - UIMenu, UIAction, (and UICommand?)
    - Any others?
    
- Layout
    - contentHuggingPriority & contentCompressionResistance
    - overlay & background modifiers
    - More constraint modifiers?

- Views
    - Link? // wraps another view and when tapped opens `self.destination`
    - Shape?
    
- Localization
    - Replicate LocalizedStringKey?
    
- ViewControllers
    - Search?
    
- Combine     
    - publisher for UIControl.state?
    
- Debug helpers?
    - Check if a view is being added multiple times during its parent's view's init


## Documentation

- Document all the things!

- Improve demo app and list what it illustrates:    
    - UIViewController subclassing 
    - Constructing a `View`'s layout that:
        - Abstract a layout to a `LayoutView` subclass
        - Uses Combine for state management
        - Keyboard avoidance
    - `FlowController`s for grouping view controllers
    - Async/await modal presentation of UIAlertController and a custom ViewController
    - A declarative `UICollectionView` layout  
