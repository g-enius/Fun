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

    @Test("Returns description for all TechnologyItem cases")
    func testAllKnownIds() {
        for item in TechnologyItem.allCases {
            let description = TechnologyDescriptions.description(for: item.rawValue)
            #expect(!description.isEmpty, "Description for '\(item)' should not be empty")
        }
    }

    @Test("Each TechnologyItem returns a unique description")
    func testUniqueDescriptions() {
        var descriptions = Set<String>()

        for item in TechnologyItem.allCases {
            let desc = TechnologyDescriptions.description(for: item.rawValue)
            descriptions.insert(desc)
        }

        #expect(descriptions.count == TechnologyItem.allCases.count)
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

    @Test("asyncAwait description mentions concurrency")
    func testAsyncAwaitContent() {
        let description = TechnologyDescriptions.description(for: TechnologyItem.asyncAwait.rawValue)
        #expect(description.lowercased().contains("async"))
    }

    @Test("asyncSequence description mentions stream or observable")
    func testAsyncSequenceContent() {
        let description = TechnologyDescriptions.description(for: TechnologyItem.asyncSequence.rawValue)
        #expect(description.lowercased().contains("asyncstream") || description.lowercased().contains("observable"))
    }

    // MARK: - Alignment with FeaturedItem Tests

    @Test("All FeaturedItem IDs have descriptions and match TechnologyItem cases")
    func testAllFeaturedItemIdsHaveDescriptions() {
        let defaultDesc = TechnologyDescriptions.description(for: "__nonexistent__")

        for item in FeaturedItem.all {
            #expect(TechnologyItem(rawValue: item.id) != nil, "FeaturedItem '\(item.id)' should map to a TechnologyItem case")
            let desc = TechnologyDescriptions.description(for: item.id)
            #expect(desc != defaultDesc, "FeaturedItem '\(item.id)' should have a specific description")
        }
    }

    @Test("TechnologyItem case count matches FeaturedItem count")
    func testCaseCountMatchesFeaturedItemCount() {
        #expect(TechnologyItem.allCases.count == FeaturedItem.all.count)
    }
}
