//
//  AppFlow.swift
//  Model
//
//  Enum representing the major app flows (login vs main)
//

import Foundation

/// Represents the major flows in the application
public enum AppFlow: Hashable, Sendable {
    /// User is not authenticated, show login screen
    case login

    /// User is authenticated, show main tab bar
    case main
}
