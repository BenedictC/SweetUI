//
//  ListSection.swift
//  SweetUI
//
//  Created by Benedict Cohen on 10/05/2025.
//



// MARK: - ListSection

public struct ListSection<SectionIdentifier: Hashable, ItemIdentifier: Hashable, HeaderType> {

    let predicate: (SectionIdentifier) -> Bool
    let header: AnyListSection<SectionIdentifier, ItemIdentifier>.HeaderKind
    let cells: [ListCell<ItemIdentifier>]
    let footer: Footer<SectionIdentifier>?

    func eraseToAnyListSection() -> AnyListSection<SectionIdentifier, ItemIdentifier> {
        AnyListSection(predicate: predicate, header: header, cells: cells, footer: footer)
    }
}
