//
//  CoreTests.swift
//  CoreTests
//
//  Unit tests for Core module
//

import Testing
@testable import FunCore

// MARK: - ServiceLocator Tests

@Suite("ServiceLocator Tests")
struct ServiceLocatorTests {

    @Test("Can register and resolve a service")
    @MainActor
    func registerAndResolve() {
        let locator = ServiceLocator()

        let testService = TestService(value: 42)
        locator.register(testService, for: .logger)

        let resolved: TestService = locator.resolve(for: .logger)
        #expect(resolved.value == 42)
    }

    @Test("isRegistered returns correct value")
    @MainActor
    func isRegisteredWorks() {
        let locator = ServiceLocator()

        #expect(locator.isRegistered(for: .logger) == false)

        locator.register(TestService(value: 1), for: .logger)
        #expect(locator.isRegistered(for: .logger) == true)
    }

    @Test("reset clears all services")
    @MainActor
    func resetClearsEverything() {
        let locator = ServiceLocator()

        locator.register(TestService(value: 1), for: .network)

        #expect(locator.isRegistered(for: .network) == true)

        locator.reset()

        #expect(locator.isRegistered(for: .network) == false)
    }
}

// MARK: - Test Helpers

private struct TestService {
    let value: Int
}
