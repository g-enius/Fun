//
//  TestHelpers.swift
//  ViewModelTests
//
//  Shared test utilities
//

import Foundation
import Testing

/// Polls a condition at 10ms intervals until it returns true or the timeout expires.
@MainActor
func waitForCondition(
    timeout: TimeInterval = 3.0,
    _ condition: @MainActor () -> Bool
) async {
    let start = CFAbsoluteTimeGetCurrent()
    while !condition() {
        if CFAbsoluteTimeGetCurrent() - start > timeout {
            Issue.record("waitForCondition timed out after \(timeout)s")
            return
        }
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms poll
    }
}
