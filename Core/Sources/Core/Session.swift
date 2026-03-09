//
//  Session.swift
//  Core
//
//  Protocol for session-scoped dependency injection lifecycle
//

import Foundation

/// A session represents a scoped set of services for a given app flow.
/// When transitioning between flows, the old session is torn down and a new one activated.
/// Each session operates on the ServiceLocator instance it was created with.
@MainActor
public protocol Session: AnyObject {
    /// Register services for this session into the ServiceLocator
    func activate()

    /// Tear down and unregister services for this session
    func teardown()
}
