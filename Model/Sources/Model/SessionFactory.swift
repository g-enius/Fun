//
//  SessionFactory.swift
//  Model
//
//  Factory protocol for creating sessions based on the current app flow
//

import FunCore

/// Creates the appropriate session for a given app flow
@MainActor
public protocol SessionFactory {
    func makeSession(for flow: AppFlow) -> Session
}
