//
//  UserProfileTests.swift
//  ModelTests
//
//  Unit tests for UserProfile model
//

import Foundation
import Testing
@testable import FunModel

@Suite("UserProfile Tests")
struct UserProfileTests {

    // MARK: - Default Initialization Tests

    @Test("Default profile has expected values")
    func testDefaultProfile() {
        let profile = UserProfile()

        #expect(profile.name == "Demo User")
        #expect(profile.email == "demo@example.com")
        #expect(profile.viewsCount == 1234)
        #expect(profile.favoritesCount == 56)
        #expect(profile.daysCount == 42)
        #expect(!profile.bio.isEmpty)
    }

    // MARK: - Custom Initialization Tests

    @Test("Custom profile uses provided values")
    func testCustomProfile() {
        let profile = UserProfile(
            name: "Jane",
            email: "jane@test.com",
            bio: "Engineer",
            viewsCount: 100,
            favoritesCount: 10,
            daysCount: 5
        )

        #expect(profile.name == "Jane")
        #expect(profile.email == "jane@test.com")
        #expect(profile.bio == "Engineer")
        #expect(profile.viewsCount == 100)
        #expect(profile.favoritesCount == 10)
        #expect(profile.daysCount == 5)
    }

    // MARK: - Demo Static Property Tests

    @Test("Demo profile matches default init")
    func testDemoMatchesDefault() {
        let demo = UserProfile.demo
        let defaultProfile = UserProfile()

        #expect(demo == defaultProfile)
    }

    // MARK: - Equatable Tests

    @Test("Profiles with same data are equal")
    func testEquality() {
        let p1 = UserProfile(name: "A", email: "a@b.com", bio: "B", viewsCount: 1, favoritesCount: 2, daysCount: 3)
        let p2 = UserProfile(name: "A", email: "a@b.com", bio: "B", viewsCount: 1, favoritesCount: 2, daysCount: 3)

        #expect(p1 == p2)
    }

    @Test("Profiles with different data are not equal")
    func testInequality() {
        let p1 = UserProfile(name: "A", email: "a@b.com", bio: "B", viewsCount: 1, favoritesCount: 2, daysCount: 3)
        let p2 = UserProfile(name: "B", email: "a@b.com", bio: "B", viewsCount: 1, favoritesCount: 2, daysCount: 3)

        #expect(p1 != p2)
    }
}

@Suite("AppError Tests")
struct AppErrorTests {

    // MARK: - Error Description Tests

    @Test("networkError has a non-nil error description")
    func testNetworkErrorDescription() {
        let error = AppError.networkError

        #expect(error.errorDescription != nil)
        #expect(!error.errorDescription!.isEmpty)
    }

    // MARK: - Equatable Tests

    @Test("Same error cases are equal")
    func testEquality() {
        #expect(AppError.networkError == AppError.networkError)
    }

    // MARK: - LocalizedError Conformance Tests

    @Test("AppError conforms to LocalizedError")
    func testLocalizedErrorConformance() {
        let error: any LocalizedError = AppError.networkError
        #expect(error.errorDescription != nil)
    }
}
