# SweetUI 🍬

SweetUI adds a little sugar to UIKit. Goals:

- Thin abstraction on top of UIKit
- Banish storyboards and nibs
- Declarative style for `UIView` subclassing 
- Reduce boiler plate code for `UIViewController` subclasses
 
Let's dig into each of these points. The core of SweetUI only depends on UIKit and Foundation and there are few methods to integrate with Combine


## Examples

The follow code is all that's required to create a view controller and its view:

```
import UIKit
import SweetUI


class FormViewController: ViewController {

    let rootView = ZStack(alignment: .center) {
        VStack(alignment: .center) {
            UILabel()
                .font(.preferredFont(forTextStyle: .largeTitle))
                .text("Hiya!")
            UILabel()
                .font(.preferredFont(forTextStyle: .subheadline))
                .text("Welcome to SweetUI")
        }
    }
    .backgroundColor(.systemBackground)
}
``` 

<img src="Images/example.jpg" width="356" height="772" alt="FormViewController screenshot">

The demo app illustrates:
- Extract the view to a `View` subclass
- Communicating with the `View` via a `ViewModel` 
- Constructing a `View`'s layout that:
    - Abstract a layout to a `LayoutView` subclass
    - Uses Combine for state management
    - Keyboard avoidance
- A `FlowController`, specifically `NavigationFlowController`  



# Miscellaneous Notes

## Fixes for `Circular reference` error

1. Create a method on the root object
2. Communicate the data via a Combine Publisher


## Adding `ViewBodyProvider` to an existing view

class CustomControl: UIControl, ViewBodyProvider {

    let body = UILabel()
        .text("Hiya!")

    init() {
        super.init(frame: .zero)
        initializeBody()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


## How to replace main.storyboard with code

1. Delete Main.Storyboard from the project
2. Navigate to Project settings -> The target for the app -> Build Settings
    - Remove the row 'UIKit Main Storyboard File Base Name'
3. In Info.plist navigate to 'Application Scene Manifest -> Scene Configuration -> Application Session Role -> Item 0' and delete the row 'Storyboard Name'
4. In SceneDelegate.swift, replace the implementation of `scene(_ scene:willConnectTo:options:)` with:
```
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else {
            preconditionFailure("Unexpected scene type \(Self.self) can only connect to a UIWindowScene.")
        }
        let window = UIWindow(windowScene: scene)
        self.window = window
        window.windowScene = scene
        window.rootViewController = RootViewController() // where RootViewController is the app's initial viewController.
        window.makeKeyAndVisible()
    }
```     
