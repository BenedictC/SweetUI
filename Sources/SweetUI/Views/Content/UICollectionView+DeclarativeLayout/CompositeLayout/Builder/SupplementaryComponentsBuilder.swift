@resultBuilder
public struct SupplementaryComponentsBuilder<ItemIdentifier> {

    public static func buildBlock(_ components: Supplement<ItemIdentifier>...) -> [Supplement<ItemIdentifier>] {
        return components
    }
}

