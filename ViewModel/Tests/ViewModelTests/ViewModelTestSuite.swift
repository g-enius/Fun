//
//  ViewModelTestSuite.swift
//  ViewModelTests
//
//  Parent suite that serializes all ViewModel test suites to prevent
//  ServiceLocator.shared.reset() from interfering across suites.
//

import Testing
import Observation

@Suite("ViewModel Tests", .serialized)
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
