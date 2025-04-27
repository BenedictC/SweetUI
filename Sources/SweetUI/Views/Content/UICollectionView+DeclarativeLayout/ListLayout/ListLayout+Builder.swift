import UIKit


@available(iOS 14, *)
extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration,
        header: LayoutHeader?,
        sections: [AnyListSection<SectionIdentifier, ItemIdentifier>],
        footer: LayoutFooter?,
        behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemIdentifier>
    ) {
        let components = ListLayoutComponents(
            configuration: configuration,
            header: header,
            footer: footer,
            sections: sections
        )
        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}
