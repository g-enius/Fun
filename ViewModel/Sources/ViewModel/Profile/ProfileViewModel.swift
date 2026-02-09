//
//  ProfileViewModel.swift
//  ViewModel
//
//  ViewModel for Profile screen
//

import Foundation

import FunCore
import FunModel

@MainActor
public class ProfileViewModel: ObservableObject {

    // MARK: - Coordinator

    private weak var coordinator: ProfileCoordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService

    // MARK: - Published State

    @Published public var userName: String
    @Published public var userEmail: String
    @Published public var userBio: String
    @Published public var viewCount: Int
    @Published public var favoritesCount: Int
    @Published public var daysCount: Int

    // MARK: - Initialization

    public init(coordinator: ProfileCoordinator?, profile: UserProfile = .demo) {
        self.coordinator = coordinator
        self.userName = profile.name
        self.userEmail = profile.email
        self.userBio = profile.bio
        self.viewCount = profile.viewsCount
        self.favoritesCount = profile.favoritesCount
        self.daysCount = profile.daysCount
    }

    // MARK: - Actions

    public func didTapSearchItems() {
        logger.log("Search Items tapped from Profile")
        coordinator?.dismiss()
        // Use deep link to switch to Items tab (decoupled navigation)
        if let url = URL(string: "funapp://tab/items") {
            coordinator?.openURL(url)
        }
    }

    public func didTapDismiss() {
        coordinator?.dismiss()
    }

    public func logout() {
        logger.log("User tapped logout from Profile", level: .info, category: .general)
        coordinator?.logout()
    }

    /// Called when the modal was dismissed by swipe-down gesture
    public func handleInteractiveDismiss() {
        coordinator?.didDismiss()
    }
}
