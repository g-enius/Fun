//
//  ViewModelTestSuite.swift
//  ViewModelTests
//
//  Parent suite grouping all ViewModel test suites.
//  No .serialized needed — each test creates its own ServiceLocator instance.
//

import Testing

@Suite("ViewModel Tests")
@MainActor
struct ViewModelTestSuite {}
