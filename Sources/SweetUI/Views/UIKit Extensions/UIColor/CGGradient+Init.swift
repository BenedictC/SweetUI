import CoreGraphics
import UIKit


// MARK: - GradientStop

public struct GradientStop {
    let color: UIColor
    let location: CGFloat
}


// MARK: - GradientStop

public extension CGGradient {

    static func make(
        colors: [UIColor],
        colorSpace: CGColorSpace? = nil
    ) -> CGGradient? {
        let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors.map { $0.cgColor } as CFArray,
            locations: nil
        )
        return gradient
    }

    static func make(
        stops: [GradientStop],
        colorSpace: CGColorSpace? = nil
    ) -> CGGradient? {
        let locations = stops.map { $0.location }
        let gradient = locations.withUnsafeBufferPointer {
            CGGradient(
                colorsSpace: colorSpace,
                colors: stops.map { $0.color.cgColor } as CFArray,
                locations: $0.baseAddress
            )
        }
        return gradient
    }
}

