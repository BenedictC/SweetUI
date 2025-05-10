

public extension ListCell {

    static func cell<CellType: ConfigurableCollectionViewCell>(
        ofType cellType: CellType? = nil
    ) -> ListCell<ItemIdentifier> where CellType.Value == ItemIdentifier {
        let reuseIdentifier = UniqueIdentifier("\(Self.self)").value
        return ListCell(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.configure(withValue: value)
                return cell
            }
        )
    }
}
