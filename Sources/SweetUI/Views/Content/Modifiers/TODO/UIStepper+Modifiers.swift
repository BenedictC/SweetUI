//import Foundation
//import UIKit
//
//
//public extension UIStepper {
//
//
//    open var isContinuous: Bool // if YES, value change events are sent any time the value changes during interaction. default = YES
//
//    open var autorepeat: Bool // if YES, press & hold repeatedly alters value. default = YES
//
//    open var wraps: Bool // if YES, value wraps from min <-> max. default = NO
//
//
//    open var value: Double // default is 0. sends UIControlEventValueChanged. clamped to min/max
//
//    open var minimumValue: Double // default 0. must be less than maximumValue
//
//    open var maximumValue: Double // default 100. must be greater than minimumValue
//
//    open var stepValue: Double // default 1. must be greater than 0
//
//
//    open func setBackgroundImage(_ image: UIImage?, for state: UIControl.State)
//
//    open func backgroundImage(for state: UIControl.State) -> UIImage?
//
//    open func setDividerImage(_ image: UIImage?, forLeftSegmentState leftState: UIControl.State, rightSegmentState rightState: UIControl.State)
//
//    open func dividerImage(forLeftSegmentState state: UIControl.State, rightSegmentState state: UIControl.State) -> UIImage?
//
//    open func setIncrementImage(_ image: UIImage?, for state: UIControl.State)
//
//    open func incrementImage(for state: UIControl.State) -> UIImage?
//    open func setDecrementImage(_ image: UIImage?, for state: UIControl.State)
//    open func decrementImage(for state: UIControl.State) -> UIImage?
//}
//
