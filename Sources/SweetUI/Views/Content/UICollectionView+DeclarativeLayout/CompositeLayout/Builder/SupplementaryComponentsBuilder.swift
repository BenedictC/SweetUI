@resultBuilder
public struct SupplementaryComponentsBuilder<ItemValue: Hashable> {

    public static func buildBlock(_ components: Supplement<ItemValue>...) -> [Supplement<ItemValue>] {
        return components
    }
}

