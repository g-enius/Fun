//
//  SceneDelegateTests.swift
//  App
//

import Testing
@testable import AppCore

@Suite("SceneDelegate Tests")
struct SceneDelegateTests {
    @Test func testAppVersion() {
        #expect(App.version == "1.0.0")
    }
}
