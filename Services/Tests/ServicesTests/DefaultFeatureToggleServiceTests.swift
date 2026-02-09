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
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.darkModeEnabled.rawValue)
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

    // MARK: - DarkModeEnabled Tests

    @Test("DarkModeEnabled defaults to false")
    func testDarkModeDefaultsFalse() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        #expect(service.darkModeEnabled == false)
    }

    @Test("DarkModeEnabled persists to UserDefaults")
    func testDarkModePersistence() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()

        service.darkModeEnabled = true
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.darkModeEnabled.rawValue) == true)

        service.darkModeEnabled = false
        #expect(UserDefaults.standard.bool(forKey: UserDefaultsKey.darkModeEnabled.rawValue) == false)
    }

    @Test("DarkModeEnabled emits via publisher")
    func testDarkModeEmitsViaPublisher() async {
        clearUserDefaults()
        let service = DefaultFeatureToggleService()
        var receivedValue: Bool?
        var cancellables = Set<AnyCancellable>()

        service.darkModePublisher
            .sink { receivedValue = $0 }
            .store(in: &cancellables)

        service.darkModeEnabled = true

        await Task.yield()

        #expect(receivedValue == true)
    }

    // MARK: - State Restoration for All Properties

    @Test("All properties restore from UserDefaults")
    func testAllPropertiesRestore() async {
        clearUserDefaults()

        UserDefaults.standard.set(false, forKey: UserDefaultsKey.featureCarousel.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.simulateErrors.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.darkModeEnabled.rawValue)

        let service = DefaultFeatureToggleService()

        #expect(service.featuredCarousel == false)
        #expect(service.simulateErrors == true)
        #expect(service.darkModeEnabled == true)
    }
}
