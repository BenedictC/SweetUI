

public extension CompositeCell {

    static func cell<CellType: ConfigurableCollectionViewCell>(
        ofType cellType: CellType? = nil,
        predicate: @escaping Predicate = { _, _ in true }
    ) -> CompositeCell<ItemIdentifier> where CellType.Value == ItemIdentifier {
        let reuseIdentifier = UniqueIdentifier("\(Self.self)").value
        return CompositeCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                guard predicate(indexPath, value) else { return nil }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.configure(withValue: value)
                return cell
            }
        )
    }
}
