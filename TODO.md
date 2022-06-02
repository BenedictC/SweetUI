# TODO

- Bindings for:
    - UISwitch.isOn // Copy and paste of button.isSelected binding
    - UISlider.value // Copy and paste of textField.text binding
    - UIStepper.value // Copy and paste of textField.text binding

- Remaining UIKit modifiers
    - Accessibility
    - Any others?
    
- Layout
    - contentHuggingPriority & contentCompressionResistance
    - overlay & background modifiers
    - More constraint modifiers?

- Views
    - CollectionView
        - List style collectionView layout
        - https://developer.apple.com/documentation/uikit/uicontentconfiguration
    - Link? // wraps another view and when tapped opens `self.destination`
    - Shape?

- ViewControllers
    - TabBarFlowController
        - Tapping on the active tab should reset navigation flows (like UIKit does)
    - Sugar for:
        - navigationItem
        - tabBarItem
        - title
    
- Combine     
    - publisher for UIControl.state?
    
- Debug helpers that only fire during `initializeBody`:
    - Check if a view already has a parent before adding/check if a view is being removed
    - Check retain count of self doesn't increment 


## Documentation
