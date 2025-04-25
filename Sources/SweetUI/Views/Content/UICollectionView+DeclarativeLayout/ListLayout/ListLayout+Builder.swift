import UIKit


@available(iOS 14, *)
extension ListLayoutCollectionViewStrategy {

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration,
        header: LayoutHeader?,
        sections: [AnyListSection<SectionIdentifier, ItemValue>],
        footer: LayoutFooter?,
        behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemValue>
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
