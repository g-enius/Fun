//
//  Session.swift
//  Core
//
//  Protocol for session-scoped dependency injection lifecycle
//

import Foundation

/// A session represents a scoped set of services for a given app flow.
/// Each session owns its own ServiceLocator — when the session is released,
/// its services are released with it. No stale services across transitions.
@MainActor
public protocol Session: AnyObject, ServiceLocatorProvider {
    /// Register services for this session into its ServiceLocator
    func activate()

    /// Tear down session-specific state (e.g. clear user data)
    func teardown()
}
