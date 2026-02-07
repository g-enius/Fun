//
//  DetailCoordinator.swift
//  Model
//
//  Coordinator protocol for Detail screen navigation
//

@MainActor
public protocol DetailCoordinator: AnyObject {
    func dismiss()
    func share(text: String)
    /// Called when the view was removed from the navigation stack by the system (e.g., back button)
    func handleSystemDismiss()
}
