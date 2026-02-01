//
//  DefaultFeatureToggleServiceTests.swift
//  Services
//
//  Unit tests for DefaultFeatureToggleService
//

import Testing
import Foundation
@testable import FunServices
@testable import FunModel

@Suite("DefaultFeatureToggleService Tests")
@MainActor
struct DefaultFeatureToggleServiceTests {

    // Helper to clear UserDefaults before each test
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: "feature.carousel")
        UserDefaults.standard.removeObject(forKey: "feature.analytics")
        UserDefaults.standard.removeObject(forKey: "feature.debugMode")
    }

    // MARK: - Initialization Tests

    @Test("Featured carousel defaults to true on first launch")
    func testFeaturedCarouselDefaultsToTrue() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.featuredCarousel == true)
    }

    @Test("Analytics defaults to false")
    func testAnalyticsDefaultsToFalse() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.featureAnalytics == false)
    }

    @Test("Debug mode defaults to false")
    func testDebugModeDefaultsToFalse() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.featureDebugMode == false)
    }

    // MARK: - Persistence Tests

    @Test("Featured carousel persists to UserDefaults")
    func testFeaturedCarouselPersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.featuredCarousel = false
        #expect(UserDefaults.standard.bool(forKey: "feature.carousel") == false)

        service.featuredCarousel = true
        #expect(UserDefaults.standard.bool(forKey: "feature.carousel") == true)
    }

    @Test("Analytics persists to UserDefaults")
    func testAnalyticsPersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.featureAnalytics = true
        #expect(UserDefaults.standard.bool(forKey: "feature.analytics") == true)

        service.featureAnalytics = false
        #expect(UserDefaults.standard.bool(forKey: "feature.analytics") == false)
    }

    @Test("Debug mode persists to UserDefaults")
    func testDebugModePersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.featureDebugMode = true
        #expect(UserDefaults.standard.bool(forKey: "feature.debugMode") == true)

        service.featureDebugMode = false
        #expect(UserDefaults.standard.bool(forKey: "feature.debugMode") == false)
    }

    // MARK: - Notification Tests

    @Test("Setting featured carousel posts notification")
    func testFeaturedCarouselPostsNotification() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()
        var notificationReceived = false

        let observer = NotificationCenter.default.addObserver(
            forName: .featureTogglesDidChange,
            object: nil,
            queue: .main
        ) { _ in
            notificationReceived = true
        }

        service.featuredCarousel = false

        // Wait a moment for notification
        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationReceived == true)

        NotificationCenter.default.removeObserver(observer)
    }

    @Test("Setting analytics posts notification")
    func testAnalyticsPostsNotification() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()
        var notificationReceived = false

        let observer = NotificationCenter.default.addObserver(
            forName: .featureTogglesDidChange,
            object: nil,
            queue: .main
        ) { _ in
            notificationReceived = true
        }

        service.featureAnalytics = true

        try? await Task.sleep(nanoseconds: 100_000_000)

        #expect(notificationReceived == true)

        NotificationCenter.default.removeObserver(observer)
    }

    // MARK: - State Restoration Tests

    @Test("Service restores state from UserDefaults")
    func testStateRestoration() async {
        clearUserDefaults()

        // Set values directly in UserDefaults
        UserDefaults.standard.set(false, forKey: "feature.carousel")
        UserDefaults.standard.set(true, forKey: "feature.analytics")
        UserDefaults.standard.set(true, forKey: "feature.debugMode")

        // Create new service instance
        let service = DefaultFeatureToggleService()

        #expect(service.featuredCarousel == false)
        #expect(service.featureAnalytics == true)
        #expect(service.featureDebugMode == true)
    }
}
