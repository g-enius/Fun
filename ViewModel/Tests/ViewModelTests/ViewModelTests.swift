//
//  ViewModelTests.swift
//  ViewModel
//
//  Entry point for ViewModel unit tests
//

import Testing
@testable import FunViewModel

@Suite("ViewModel Module Tests")
struct ViewModelTests {
    @Test("ViewModel module loads correctly")
    func testViewModelModuleLoads() async {
        // Basic sanity check that the module loads
        #expect(true)
    }
}
