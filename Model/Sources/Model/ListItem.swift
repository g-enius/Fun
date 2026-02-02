//
//  ListItem.swift
//  Model
//

import Foundation

public struct ListItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let category: String
    public let timeLabel: String

    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String = "",
        category: String = "General",
        timeLabel: String = "2 sec."
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.category = category
        self.timeLabel = timeLabel
    }
}

public extension ListItem {
    static let item1 = ListItem(
        id: "item1",
        title: "Item 1",
        subtitle: "Description for item 1",
        category: "Featured",
        timeLabel: "3 sec."
    )
    static let item2 = ListItem(
        id: "item2",
        title: "Item 2",
        subtitle: "Description for item 2",
        category: "General",
        timeLabel: "2 sec."
    )
    static let item3 = ListItem(
        id: "item3",
        title: "Item 3",
        subtitle: "Description for item 3",
        category: "General",
        timeLabel: "2 sec."
    )
    static let item4 = ListItem(
        id: "item4",
        title: "Item 4",
        subtitle: "Description for item 4",
        category: "General",
        timeLabel: "2 sec."
    )
    static let item5 = ListItem(
        id: "item5",
        title: "Item 5",
        subtitle: "Description for item 5",
        category: "General",
        timeLabel: "2 sec."
    )

    static let allItems: [ListItem] = [.item1, .item2, .item3, .item4, .item5]
}
