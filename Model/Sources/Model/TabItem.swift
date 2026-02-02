import Foundation

public struct TabItem: Identifiable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let iconName: String
    public let selectedIconName: String

    public init(id: Int, title: String, iconName: String, selectedIconName: String? = nil) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.selectedIconName = selectedIconName ?? iconName + ".fill"
    }
}

public extension TabItem {
    static let tab1 = TabItem(id: 0, title: "Tab 1", iconName: "1.circle", selectedIconName: "1.circle.fill")
    static let tab2 = TabItem(id: 1, title: "Tab 2", iconName: "2.circle", selectedIconName: "2.circle.fill")
    static let tab3 = TabItem(
        id: 2,
        title: "Item",
        iconName: "square.grid.2x2",
        selectedIconName: "square.grid.2x2.fill"
    )
    static let tab4 = TabItem(id: 3, title: "Tab 4", iconName: "4.circle", selectedIconName: "4.circle.fill")
    static let settings = TabItem(id: 4, title: "Settings", iconName: "gearshape", selectedIconName: "gearshape.fill")

    static let allTabs: [TabItem] = [.tab1, .tab2, .tab3, .tab4, .settings]
}
