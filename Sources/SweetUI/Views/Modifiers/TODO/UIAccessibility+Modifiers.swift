import Foundation
import UIKit


public extension UIView {
/*

 @interface NSObject (UIAccessibility)

 /*
  Return YES if the receiver should be exposed as an accessibility element.
  default == NO
  default on UIKit controls == YES
  Setting the property to YES will cause the receiver to be visible to assistive applications.
  */
 @property (nonatomic) BOOL isAccessibilityElement;

 /*
  Returns the localized label that represents the element.
  If the element does not display text (an icon for example), this method
  should return text that best labels the element. For example: "Play" could be used for
  a button that is used to play music. "Play button" should not be used, since there is a trait
  that identifies the control is a button.
  default == nil
  default on UIKit controls == derived from the title
  Setting the property will change the label that is returned to the accessibility client.
  */
 @property (nullable, nonatomic, copy) NSString *accessibilityLabel;

 /*
  The underlying attributed version of the accessibility label. Setting this property will change the
  value of the accessibilityLabel property and vice-versa.
  */
 @property (nullable, nonatomic, copy) NSAttributedString *accessibilityAttributedLabel API_AVAILABLE(ios(11.0),tvos(11.0));

 /*
  Returns a localized string that describes the result of performing an action on the element, when the result is non-obvious.
  The hint should be a brief phrase.
  For example: "Purchases the item." or "Downloads the attachment."
  default == nil
  Setting the property will change the hint that is returned to the accessibility client.
  */
 @property (nullable, nonatomic, copy) NSString *accessibilityHint;

 /*
  The underlying attributed version of the accessibility hint. Setting this property will change the
  value of the accessibilityHint property and vice-versa.
  */
 @property (nullable, nonatomic, copy) NSAttributedString *accessibilityAttributedHint API_AVAILABLE(ios(11.0),tvos(11.0));

 /*
  Returns a localized string that represents the value of the element, such as the value
  of a slider or the text in a text field. Use only when the label of the element
  differs from a value. For example: A volume slider has a label of "Volume", but a value of "60%".
  default == nil
  default on UIKit controls == values for appropriate controls
  Setting the property will change the value that is returned to the accessibility client.
  */
 @property (nullable, nonatomic, copy) NSString *accessibilityValue;

 /*
  The underlying attributed version of the accessibility value. Setting this property will change the
  value of the accessibilityValue property and vice-versa.
  */
 @property (nullable, nonatomic, copy) NSAttributedString *accessibilityAttributedValue API_AVAILABLE(ios(11.0),tvos(11.0));

 /*
  Returns a UIAccessibilityTraits mask that is the OR combination of
  all accessibility traits that best characterize the element.
  See UIAccessibilityConstants.h for a list of traits.
  When overriding this method, remember to combine your custom traits
  with [super accessibilityTraits].
  default == UIAccessibilityTraitNone
  default on UIKit controls == traits that best characterize individual controls.
  Setting the property will change the traits that are returned to the accessibility client.
  */
 @property (nonatomic) UIAccessibilityTraits accessibilityTraits;

 /*
  Returns the frame of the element in screen coordinates.
  default == CGRectZero
  default on UIViews == the frame of the view
  Setting the property will change the frame that is returned to the accessibility client.
  */
 @property (nonatomic) CGRect accessibilityFrame;

 // The accessibilityFrame is expected to be in screen coordinates.
 // To help convert the frame to screen coordinates, use the following method.
 // The rect should exist in the view space of the UIView argument.
 UIKIT_EXTERN CGRect UIAccessibilityConvertFrameToScreenCoordinates(CGRect rect, UIView *view) API_AVAILABLE(ios(7.0));

 /*
  Returns the path of the element in screen coordinates.
  default == nil
  Setting the property, or overriding the method, will cause the assistive technology to prefer the path over the accessibility.
  frame when highlighting the element.
  */
 @property (nullable, nonatomic, copy) UIBezierPath *accessibilityPath API_AVAILABLE(ios(7.0));

 // The accessibilityPath is expected to be in screen coordinates.
 // To help convert the path to screen coordinates, use the following method.
 // The path should exist in the view space of the UIView argument.
 UIKIT_EXTERN UIBezierPath *UIAccessibilityConvertPathToScreenCoordinates(UIBezierPath *path, UIView *view) API_AVAILABLE(ios(7.0));

 /*
  Returns the activation point for an accessible element in screen coordinates.
  default == Mid-point of the accessibilityFrame.
  */
 @property (nonatomic) CGPoint accessibilityActivationPoint API_AVAILABLE(ios(5.0));

 /*
  Returns the language code that the element's label, value and hint should be spoken in.
  If no language is set, the user's language is used.
  The format for the language code should follow Internet BCP 47 for language tags.
  For example, en-US specifies U.S. English.
  default == nil
  */
 @property (nullable, nonatomic, strong) NSString *accessibilityLanguage;

 /*
  Marks all the accessible elements contained within as hidden.
  default == NO
  */
 @property (nonatomic) BOOL accessibilityElementsHidden API_AVAILABLE(ios(5.0));

 /*
  Informs whether the receiving view should be considered modal by accessibility. If YES, then
  elements outside this view will be ignored. Only elements inside this view will be exposed.
  default == NO
  */
 @property (nonatomic) BOOL accessibilityViewIsModal API_AVAILABLE(ios(5.0));

 /*
  Forces children elements to be grouped together regardless of their position on screen.
  For example, your app may show items that are meant to be grouped together in vertical columns.
  By default, VoiceOver will navigate those items in horizontal rows. If shouldGroupAccessibilityChildren is set on
  a parent view of the items in the vertical column, VoiceOver will navigate the order correctly.
  default == NO
  */
 @property (nonatomic) BOOL shouldGroupAccessibilityChildren API_AVAILABLE(ios(6.0));

 /*
  Some assistive technologies allow the user to select a parent view or container to navigate its elements.
  This property allows an app to specify whether that behavior should apply to the receiver.
  Currently, this property only affects Switch Control, not VoiceOver or other assistive technologies.
  See UIAccessibilityConstants.h for the list of supported values.
  default == UIAccessibilityNavigationStyleAutomatic
  */
 @property (nonatomic) UIAccessibilityNavigationStyle accessibilityNavigationStyle API_AVAILABLE(ios(8.0));

 /*
  Returns whether the element performs an action based on user interaction.
  For example, a button that causes UI to update when it is tapped should return YES.
  A label whose only purpose is to display information should return NO.
  default == derived from other accessibility properties (for example, an element with UIAccessibilityTraitNotEnabled returns NO)
  */
 @property (nonatomic) BOOL accessibilityRespondsToUserInteraction API_AVAILABLE(ios(13.0),tvos(13.0));

 /*
  Returns the localized label(s) that should be provided by the user to refer to this element.
  Use this property when the accessibilityLabel is not appropriate for dictated or typed input.
  For example, an element that contains additional descriptive information in its accessibilityLabel can return a more concise label.
  The primary label should be first in the array, optionally followed by alternative labels in descending order of importance.
  If this property returns an empty or invalid value, the accessibilityLabel will be used instead.
  default == an empty array
  default on UIKit controls == an array with an appropriate label, if different from accessibilityLabel
  */
 @property (null_resettable, nonatomic, strong) NSArray<NSString *> *accessibilityUserInputLabels API_AVAILABLE(ios(13.0),tvos(13.0));

 /*
  The underlying attributed versions of the accessibility user input label(s).
  Setting this property will change the value of the accessibilityUserInputLabels property and vice versa.
  */
 @property (null_resettable, nonatomic, copy) NSArray<NSAttributedString *> *accessibilityAttributedUserInputLabels API_AVAILABLE(ios(13.0),tvos(13.0));

 /*
  The elements considered to be the headers for this element. May be set on an instance of
  UIAccessibilityElement, a View or a View Controller. The accessibility container chain,
  and associated view controllers where appropriate, will be consulted.
  To avoid retain cycles, a weak copy of the elements will be held.
  */
 @property(nullable, nonatomic, copy) NSArray *accessibilityHeaderElements UIKIT_AVAILABLE_TVOS_ONLY(9_0);

 /*
  Returns an appropriate, named context to help identify and classify the type of text inside this element.
  This can be used by assistive technologies to choose an appropriate way to output the text.
  For example, when encountering a source coding context, VoiceOver could choose to speak all punctuation.
  To specify a substring within the textual context, use the UIAccessibilityTextAttributeContext attributed key.
  default == nil
  */
 @property(nullable, nonatomic, strong) UIAccessibilityTextualContext accessibilityTextualContext API_AVAILABLE(ios(13.0), tvos(13.0));


 @end


 */
}


// MARK: - UIAccessibilityAction

public extension UIView {

    func accessibilityCustomActions(_ value: [UIAccessibilityCustomAction]?) -> Self {
        accessibilityCustomActions = value
        return self
    }
}


// MARK: - UIAccessibilityDragging

public extension UIView {

    func accessibilityDragSourceDescriptors(_ value: [UIAccessibilityLocationDescriptor]?) -> Self {
        accessibilityDragSourceDescriptors = value
        return self
    }

    func accessibilityDropPointDescriptors(_ value: [UIAccessibilityLocationDescriptor]) -> Self {
        accessibilityDropPointDescriptors = value
        return self
    }
}
