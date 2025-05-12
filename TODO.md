# TODO

- BoundarySupplement
    - LayoutHeader/LayoutFooter inits
    - SectionHeader/SectionFooter inits
- SectionSupplement
- GroupSupplement
- GroupItemSupplement

- CustomGroup




- Remove `preconditionFailure`s in collectionView layout where possible.

- Bindings and inits for:
    - UIPageControl + UIPageControlProgress
    - UISegmentedControl
    - UISlider.value // Copy and paste of textField.text binding?
    - UIStepper.value // Copy and paste of textField.text binding?
    
- Remaining UIKit modifiers
    - GestureRecognizers
    - UIMenu, UIAction, UISwipeAction (and UICommand?)
    - Any others?

- ViewControllers
    - UINavigationItem.searchController ???
    
- Animation!
    
- Localization
    - Replicate LocalizedStringKey?
    
- Accessibility?
    
- Rationalize ViewController init. 
- Rationalize View init
- Rationalize CollectionView factory

- Content Views:
    - Link? // wraps another view and when tapped opens `self.destination`
    
- Debug helpers?
    - Bug: calls to cancellableStorage during awake cause an erroneous runtime warning
    - Check if a view is being added multiple times during its parent's view's init

- Bug in UIKit or SweetUI?: 
    When: a ViewController is not inside a UINavigationController 
        and the ViewController's rootView is a ScrollView (or UIScrollView)
        and the content of the scrollView does not vertically fill the scrollView 
    Then: the ScrollView fails to adjust its contentInset to avoid the top safe area


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
