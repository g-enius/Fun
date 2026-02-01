//
//  UITests.swift
//  UI
//
//  Entry point for UI unit tests
//

import Testing
@testable import FunUI

@Suite("UI Module Tests")
struct UITests {
    @Test("UI module loads correctly")
    func testUIModuleLoads() async {
        // Basic sanity check that the module loads
        #expect(true)
    }
}
