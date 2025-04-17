
@available(*, deprecated, message: "Use ContentAlignment instead of ZAxisAlignment")
public typealias ZAxisAlignment = ContentAlignment

public enum ContentAlignment {
    case fill
    case topLeft, top, topRight
    case left, center, right
    case bottomLeft, bottom, bottomRight

    case topLeading, topTrailing
    case leading, trailing
    case bottomLeading, bottomTrailing
}
