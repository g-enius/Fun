//
//  ViewModelTestSuite.swift
//  ViewModelTests
//
//  Parent suite that serializes all ViewModel test suites to prevent
//  ServiceLocator.shared.reset() from interfering across suites.
//

import Testing

@Suite("ViewModel Tests", .serialized)
@MainActor
struct ViewModelTestSuite {}
