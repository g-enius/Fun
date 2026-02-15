//
//  DefaultFeatureToggleServiceTests.swift
//  Services
//
//  Unit tests for DefaultFeatureToggleService
//

import Testing
import Foundation
import Combine
@testable import FunServices
@testable import FunModel

@Suite("DefaultFeatureToggleService Tests", .serialized)
@MainActor
struct DefaultFeatureToggleServiceTests {

    // Helper to clear UserDefaults before each test
    private func clearUserDefaults() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.featureCarousel.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.simulateErrors.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.aiSummary.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.appearanceMode.rawValue)
    }

    // MARK: - Initialization Tests

    @Test("Featured carousel defaults to true on first launch")
    func testFeaturedCarouselDefaultsToTrue() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.featuredCarousel == true)
    }

    // MARK: - Persistence Tests

    @Test("Featured carousel persists to UserDefaults")
    func testFeaturedCarouselPersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.featuredCarousel = false
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.featureCarousel.rawValue) == false)

        service.featuredCarousel = true
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.featureCarousel.rawValue) == true)
    }

    // MARK: - Combine Publisher Tests

    @Test("Setting featured carousel emits via publisher")
    func testFeaturedCarouselEmitsViaPublisher() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()
        var receivedValue: Bool?
        var cancellables = Set<AnyCancellable>()

        service.featuredCarouselPublisher
            .sink { receivedValue = $0 }
            .store(in: &cancellables)

        service.featuredCarousel = false

        // Yield to allow publisher propagation
        await Task.yield()

        #expect(receivedValue == false)
    }

    // MARK: - State Restoration Tests

    @Test("Service restores state from UserDefaults")
    func testStateRestoration() async {
        clearUserDefaults()

        // Set values directly in UserDefaults
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.featureCarousel.rawValue)

        // Create new service instance
        let service = DefaultFeatureToggleService()

        #expect(service.featuredCarousel == false)
    }

    // MARK: - SimulateErrors Tests

    @Test("SimulateErrors defaults to false")
    func testSimulateErrorsDefaultsFalse() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.simulateErrors == false)
    }

    @Test("SimulateErrors persists to UserDefaults")
    func testSimulateErrorsPersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.simulateErrors = true
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.simulateErrors.rawValue) == true)

        service.simulateErrors = false
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.simulateErrors.rawValue) == false)
    }

    @Test("SimulateErrors emits via publisher")
    func testSimulateErrorsEmitsViaPublisher() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()
        var receivedValue: Bool?
        var cancellables = Set<AnyCancellable>()

        service.simulateErrorsPublisher
            .sink { receivedValue = $0 }
            .store(in: &cancellables)

        service.simulateErrors = true

        await Task.yield()

        #expect(receivedValue == true)
    }

    // MARK: - AppearanceMode Tests

    @Test("AppearanceMode defaults to system")
    func testAppearanceModeDefaultsToSystem() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.appearanceMode == .system)
    }

    @Test("AppearanceMode persists to UserDefaults")
    func testAppearanceModePersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.appearanceMode = .dark
        #expect(UserDefaults.standard.string(forKey: UserDefaultsKey.appearanceMode.rawValue) == "dark")

        service.appearanceMode = .light
        #expect(UserDefaults.standard.string(forKey: UserDefaultsKey.appearanceMode.rawValue) == "light")

        service.appearanceMode = .system
        #expect(UserDefaults.standard.string(forKey: UserDefaultsKey.appearanceMode.rawValue) == "system")
    }

    @Test("AppearanceMode emits via publisher")
    func testAppearanceModeEmitsViaPublisher() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()
        var receivedValue: AppearanceMode?
        var cancellables = Set<AnyCancellable>()

        service.appearanceModePublisher
            .sink { receivedValue = $0 }
            .store(in: &cancellables)

        service.appearanceMode = .dark

        await Task.yield()

        #expect(receivedValue == .dark)
    }

    // MARK: - AI Summary Tests

    @Test("AI Summary defaults to true")
    func testAISummaryDefaultsToTrue() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.aiSummary == true)
    }

    @Test("AI Summary persists to UserDefaults")
    func testAISummaryPersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.aiSummary = false
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.aiSummary.rawValue) == false)

        service.aiSummary = true
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.aiSummary.rawValue) == true)
    }

    @Test("AI Summary emits via publisher")
    func testAISummaryEmitsViaPublisher() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()
        var receivedValue: Bool?
        var cancellables = Set<AnyCancellable>()

        service.aiSummaryPublisher
            .sink { receivedValue = $0 }
            .store(in: &cancellables)

        service.aiSummary = false

        await Task.yield()

        #expect(receivedValue == false)
    }

    // MARK: - State Restoration for All Properties

    @Test("All properties restore from UserDefaults")
    func testAllPropertiesRestore() async {
        clearUserDefaults()

        UserDefaults.standard.set(false, forKey: UserDefaultsKey.featureCarousel.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.simulateErrors.rawValue)
        UserDefaults.standard.set(false, forKey: UserDefaultsKey.aiSummary.rawValue)
        UserDefaults.standard.set("dark", forKey: UserDefaultsKey.appearanceMode.rawValue)

        let service = DefaultFeatureToggleService()

        #expect(service.featuredCarousel == false)
        #expect(service.simulateErrors == true)
        #expect(service.aiSummary == false)
        #expect(service.appearanceMode == .dark)
    }
}
