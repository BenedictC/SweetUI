@resultBuilder
public struct SupplementaryComponentsBuilder<ItemIdentifier: Hashable> {

    public static func buildBlock(_ components: Supplement<ItemIdentifier>...) -> [Supplement<ItemIdentifier>] {
        return components
    }
}

