

public extension CompositeCell {

    static func cell<CellType: ConfigurableCollectionViewCell>(
        ofType cellType: CellType.Type = CellType.self,
        configure: @escaping (CellType) -> Void = { _ in }
    ) -> CompositeCell<ItemIdentifier> where CellType.Value == ItemIdentifier {
        let reuseIdentifier = UniqueIdentifier("\(Self.self)").value
        return CompositeCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                configure(cell)
                cell.configure(withValue: value)
                return cell
            }
        )
    }
}
