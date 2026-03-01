//
//  DeepLinkTests.swift
//  ModelTests
//
//  Unit tests for DeepLink URL parsing
//

import Foundation
import Testing
@testable import FunModel

@Suite("DeepLink Tests")
struct DeepLinkTests {

    // MARK: - Tab Deep Links

    @Test("Parse tab/home deep link")
    func parseTabHome() {
        let url = URL(string: "funapp://tab/home")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == DeepLink.tab(.home))
    }

    @Test("Parse tab/items deep link")
    func parseTabItems() {
        let url = URL(string: "funapp://tab/items")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == DeepLink.tab(.items))
    }

    @Test("Parse tab/settings deep link")
    func parseTabSettings() {
        let url = URL(string: "funapp://tab/settings")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == DeepLink.tab(.settings))
    }

    @Test("Parse tab/search as items alias")
    func parseTabSearchAlias() {
        let url = URL(string: "funapp://tab/search")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == DeepLink.tab(.items))
    }

    // MARK: - Item Deep Links

    @Test("Parse item deep link with ID")
    func parseItemWithId() {
        let url = URL(string: "funapp://item/swiftui")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == DeepLink.item(id: "swiftui"))
    }

    @Test("Parse item deep link with different ID")
    func parseItemWithDifferentId() {
        let url = URL(string: "funapp://item/asyncsequence")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == DeepLink.item(id: "asyncsequence"))
    }

    // MARK: - Profile Deep Link

    @Test("Parse profile deep link")
    func parseProfile() {
        let url = URL(string: "funapp://profile")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == DeepLink.profile)
    }

    // MARK: - Invalid Deep Links

    @Test("Return nil for wrong scheme")
    func wrongSchemeReturnsNil() {
        let url = URL(string: "https://tab/items")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == nil)
    }

    @Test("Return nil for unknown host")
    func unknownHostReturnsNil() {
        let url = URL(string: "funapp://unknown/path")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == nil)
    }

    @Test("Return nil for tab without path")
    func tabWithoutPathReturnsNil() {
        let url = URL(string: "funapp://tab")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == nil)
    }

    @Test("Return nil for invalid tab name")
    func invalidTabNameReturnsNil() {
        let url = URL(string: "funapp://tab/invalid")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == nil)
    }

    @Test("Return nil for item without ID")
    func itemWithoutIdReturnsNil() {
        let url = URL(string: "funapp://item")!
        let deepLink = DeepLink(url: url)

        #expect(deepLink == nil)
    }

    // MARK: - Case Insensitivity

    @Test("Tab name parsing is case insensitive")
    func tabNameCaseInsensitive() {
        let upperUrl = URL(string: "funapp://tab/HOME")!
        let mixedUrl = URL(string: "funapp://tab/Items")!

        #expect(DeepLink(url: upperUrl) == DeepLink.tab(.home))
        #expect(DeepLink(url: mixedUrl) == DeepLink.tab(.items))
    }
}

@Suite("TabIndex Tests")
struct TabIndexTests {

    // MARK: - from(name:) Tests

    @Test("Parse home tab name")
    func parseHomeName() {
        #expect(TabIndex.from(name: "home") == .home)
    }

    @Test("Parse items tab name")
    func parseItemsName() {
        #expect(TabIndex.from(name: "items") == .items)
    }

    @Test("Parse settings tab name")
    func parseSettingsName() {
        #expect(TabIndex.from(name: "settings") == .settings)
    }

    @Test("Parse search as items alias")
    func parseSearchAlias() {
        #expect(TabIndex.from(name: "search") == .items)
    }

    @Test("Return nil for invalid name")
    func invalidNameReturnsNil() {
        #expect(TabIndex.from(name: "invalid") == nil)
        #expect(TabIndex.from(name: "") == nil)
        #expect(TabIndex.from(name: "profile") == nil)
    }

    @Test("Name parsing is case insensitive")
    func caseInsensitive() {
        #expect(TabIndex.from(name: "HOME") == .home)
        #expect(TabIndex.from(name: "Items") == .items)
        #expect(TabIndex.from(name: "SETTINGS") == .settings)
    }

    // MARK: - Raw Value Tests

    @Test("Tab indices have correct raw values")
    func rawValues() {
        #expect(TabIndex.home.rawValue == 0)
        #expect(TabIndex.items.rawValue == 1)
        #expect(TabIndex.settings.rawValue == 2)
    }
}
