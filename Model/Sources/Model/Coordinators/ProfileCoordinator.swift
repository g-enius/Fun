//
//  ProfileCoordinator.swift
//  Model
//
//  Coordinator protocol for Profile screen navigation
//

import Foundation

@MainActor
public protocol ProfileCoordinator: AnyObject {
    func dismiss()
    func logout()
    func openURL(_ url: URL)
}
