import UIKit


public extension SomeView {

    func mask<MaskView: UIView>(
        sizedBy: MaskSizingView = .content,
        alignment: ContentAlignment = .fill,
        view mask: () -> MaskView
    ) -> Mask<Self, MaskView> {
        Mask(sizingView: sizedBy, alignment: alignment, content: self, mask: mask())
    }

    func mask<MaskView: UIView>(
        sizedBy: MaskSizingView = .content,
        alignment: ContentAlignment = .fill,
        view mask: MaskView
    ) -> Mask<Self, MaskView> {
        Mask(sizingView: sizedBy, alignment: alignment, content: self, mask: mask)
    }
}
