//
//  TechnologyDescriptionsTests.swift
//  ModelTests
//
//  Unit tests for TechnologyDescriptions
//

import Foundation
import Testing
@testable import FunModel

@Suite("TechnologyDescriptions Tests")
struct TechnologyDescriptionsTests {

    // MARK: - Known IDs Tests

    @Test("Returns description for all known item IDs")
    func testAllKnownIds() {
        let knownIds = [
            "asyncawait", "combine", "swiftui", "coordinator",
            "mvvm", "spm", "servicelocator", "protocol",
            "featuretoggles", "oslog", "swift6", "swifttesting",
            "snapshot", "accessibility"
        ]

        for id in knownIds {
            let description = TechnologyDescriptions.description(for: id)
            #expect(!description.isEmpty, "Description for '\(id)' should not be empty")
        }
    }

    @Test("Each known ID returns a unique description")
    func testUniqueDescriptions() {
        let ids = ["asyncawait", "combine", "swiftui", "coordinator", "mvvm", "spm"]
        var descriptions = Set<String>()

        for id in ids {
            let desc = TechnologyDescriptions.description(for: id)
            descriptions.insert(desc)
        }

        #expect(descriptions.count == ids.count)
    }

    // MARK: - Default Description Tests

    @Test("Unknown ID returns default description")
    func testUnknownIdReturnsDefault() {
        let description = TechnologyDescriptions.description(for: "unknown_id")
        #expect(!description.isEmpty)
    }

    @Test("Empty ID returns default description")
    func testEmptyIdReturnsDefault() {
        let description = TechnologyDescriptions.description(for: "")
        #expect(!description.isEmpty)
    }

    @Test("Unknown IDs return same default description")
    func testUnknownIdsSameDefault() {
        let desc1 = TechnologyDescriptions.description(for: "nonexistent1")
        let desc2 = TechnologyDescriptions.description(for: "nonexistent2")

        #expect(desc1 == desc2)
    }

    // MARK: - Content Validation Tests

    @Test("asyncawait description mentions concurrency")
    func testAsyncAwaitContent() {
        let description = TechnologyDescriptions.description(for: "asyncawait")
        #expect(description.lowercased().contains("async"))
    }

    @Test("combine description mentions reactive")
    func testCombineContent() {
        let description = TechnologyDescriptions.description(for: "combine")
        #expect(description.lowercased().contains("reactive") || description.lowercased().contains("combine"))
    }

    // MARK: - Alignment with FeaturedItem Tests

    @Test("All FeaturedItem IDs have descriptions")
    func testAllFeaturedItemIdsHaveDescriptions() {
        let defaultDesc = TechnologyDescriptions.description(for: "__nonexistent__")

        for item in FeaturedItem.all {
            let desc = TechnologyDescriptions.description(for: item.id)
            #expect(desc != defaultDesc, "FeaturedItem '\(item.id)' should have a specific description")
        }
    }
}
