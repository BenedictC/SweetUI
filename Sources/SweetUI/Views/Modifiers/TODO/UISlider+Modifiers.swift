//import Foundation
//import UIKit
////
//
//public extension UISlider {
//
//
//    open var value: Float // default 0.0. this value will be pinned to min/max
//
//    open var minimumValue: Float // default 0.0. the current value may change if outside new min value
//
//    open var maximumValue: Float // default 1.0. the current value may change if outside new max value
//
//
//    open var minimumValueImage: UIImage? // default is nil. image that appears to left of control (e.g. speaker off)
//
//    open var maximumValueImage: UIImage? // default is nil. image that appears to right of control (e.g. speaker max)
//
//
//    open var isContinuous: Bool // if set, value change events are generated any time the value changes due to dragging. default = YES
//
//
//    open var minimumTrackTintColor: UIColor?
//
//    open var maximumTrackTintColor: UIColor?
//
//    open var thumbTintColor: UIColor?
//
//    open func setValue(_ value: Float, animated: Bool) // move slider at fixed velocity (i.e. duration depends on distance). does not send action
//
//
//    // set the images for the slider. there are 3, the thumb which is centered by default and the track. You can specify different left and right track
//    // e.g blue on the left as you increase and white to the right of the thumb. The track images should be 3 part resizable (via UIImage's resizableImage methods) along the direction that is longer
//
//    open func setThumbImage(_ image: UIImage?, for state: UIControl.State)
//
//    open func setMinimumTrackImage(_ image: UIImage?, for state: UIControl.State)
//
//    open func setMaximumTrackImage(_ image: UIImage?, for state: UIControl.State)
//}
//
