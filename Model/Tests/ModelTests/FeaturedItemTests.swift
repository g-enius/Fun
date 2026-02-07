//
//  FeaturedItemTests.swift
//  ModelTests
//
//  Unit tests for FeaturedItem model
//

import Foundation
import Testing
@testable import FunModel

@Suite("FeaturedItem Tests")
struct FeaturedItemTests {

    // MARK: - Initialization Tests

    @Test("Full initializer sets all properties")
    func testFullInitializer() {
        let item = FeaturedItem(
            id: "test-id",
            title: "Test Title",
            subtitle: "Test Subtitle",
            iconName: "star",
            iconColor: .blue,
            category: "Test Category",
            timeLabel: "5 sec."
        )

        #expect(item.id == "test-id")
        #expect(item.title == "Test Title")
        #expect(item.subtitle == "Test Subtitle")
        #expect(item.iconName == "star")
        #expect(item.iconColor == .blue)
        #expect(item.category == "Test Category")
        #expect(item.timeLabel == "5 sec.")
    }

    @Test("Full initializer uses default values")
    func testFullInitializerDefaults() {
        let item = FeaturedItem(
            title: "Title",
            subtitle: "Subtitle",
            iconName: "star",
            iconColor: .red
        )

        #expect(item.title == "Title")
        #expect(item.category == "General")
        #expect(item.timeLabel == "2 sec.")
        #expect(!item.id.isEmpty)
    }

    @Test("Convenience initializer uses color parameter")
    func testConvenienceInitializer() {
        let item = FeaturedItem(
            id: "conv-id",
            title: "Conv Title",
            subtitle: "Conv Subtitle",
            color: .green
        )

        #expect(item.id == "conv-id")
        #expect(item.title == "Conv Title")
        #expect(item.iconName == "star.fill")
        #expect(item.iconColor == .green)
        #expect(item.category == "General")
        #expect(item.timeLabel == "2 sec.")
    }

    // MARK: - Static Items Tests

    @Test("All static items have unique IDs")
    func testStaticItemsUniqueIds() {
        let allItems = FeaturedItem.all
        let ids = Set(allItems.map(\.id))

        #expect(ids.count == allItems.count)
    }

    @Test("All carousel sets contain exactly 2 items")
    func testCarouselSetsHaveTwoItems() {
        for (index, set) in FeaturedItem.allCarouselSets.enumerated() {
            #expect(set.count == 2, "Carousel set \(index) has \(set.count) items, expected 2")
        }
    }

    @Test("allCarouselSets has 7 sets")
    func testAllCarouselSetsCount() {
        #expect(FeaturedItem.allCarouselSets.count == 7)
    }

    @Test("all contains 14 items")
    func testAllItemsCount() {
        #expect(FeaturedItem.all.count == 14)
    }

    @Test("all matches flattened carousel sets")
    func testAllMatchesFlattenedSets() {
        let flattened = FeaturedItem.allCarouselSets.flatMap { $0 }
        #expect(FeaturedItem.all == flattened)
    }

    // MARK: - Known Items Tests

    @Test("asyncAwait has correct properties")
    func testAsyncAwaitItem() {
        let item = FeaturedItem.asyncAwait
        #expect(item.id == "asyncawait")
        #expect(item.title == "Async/Await")
        #expect(item.category == "Concurrency")
    }

    @Test("swiftUI has correct properties")
    func testSwiftUIItem() {
        let item = FeaturedItem.swiftUI
        #expect(item.id == "swiftui")
        #expect(item.title == "SwiftUI")
        #expect(item.category == "UI Framework")
    }

    // MARK: - Equatable Tests

    @Test("Items with same properties are equal")
    func testEquality() {
        let item1 = FeaturedItem(id: "same", title: "T", subtitle: "S", iconName: "star", iconColor: .blue)
        let item2 = FeaturedItem(id: "same", title: "T", subtitle: "S", iconName: "star", iconColor: .blue)

        #expect(item1 == item2)
    }

    @Test("Items with different IDs are not equal")
    func testInequality() {
        let item1 = FeaturedItem(id: "id1", title: "T", subtitle: "S", iconName: "star", iconColor: .blue)
        let item2 = FeaturedItem(id: "id2", title: "T", subtitle: "S", iconName: "star", iconColor: .blue)

        #expect(item1 != item2)
    }
}
