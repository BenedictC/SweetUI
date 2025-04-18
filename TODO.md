# TODO

- Rationalize ViewController init. 
- Rationalize View init
- Rationalize CollectionView factory

- CollectionViewSnapshot is not concurrency safe! 
    - To be safe, getting the snapshot must be async because there may be an update operation in progress. 
    - This means a propertyWrapper is not well suited because propertyWrapper's accessors cannot be async    

- Bindings and inits for:
    - UISegmentedControl
    - UISlider.value // Copy and paste of textField.text binding?
    - UIStepper.value // Copy and paste of textField.text binding?
    - UIPageControl + UIPageControlProgress
    
- Bug in UIKit or SweetUI?: 
    When: a ViewController is not inside a UINavigationController 
        and the ViewController's rootView is a ScrollView (or UIScrollView)
        and the content of the scrollView does not vertically fill the scrollView 
    Then: the ScrollView fails to adjust its contentInset to avoid the top safe area

- Remaining UIKit modifiers
    - GestureRecognizers
    - UIMenu, UIAction, (and UICommand?)
    - Any others?

- Content Views:
    - Link? // wraps another view and when tapped opens `self.destination`
    
- Localization
    - Replicate LocalizedStringKey?
    
- Accessibility?
    
- ViewControllers
    - Search?
    
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
