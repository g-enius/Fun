//
//  ViewModelTestSuite.swift
//  ViewModelTests
//
//  Parent suite grouping all ViewModel test suites.
//  No .serialized needed — each test creates its own ServiceLocator instance.
//

import Testing
import Observation

@Suite("ViewModel Tests")
@MainActor
struct ViewModelTestSuite {}

/// Yields the MainActor until an observed @Observable property changes.
/// Call AFTER triggering the action — @MainActor serialization ensures
/// the observation task can't run until we suspend at withCheckedContinuation.
@MainActor
func awaitObservation(_ apply: () -> Void) async {
    await withCheckedContinuation { continuation in
        withObservationTracking(apply) {
            continuation.resume()
        }
    }
}
