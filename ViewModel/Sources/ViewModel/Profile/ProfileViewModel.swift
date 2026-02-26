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

    // MARK: - Navigation Closures

    public var onDismiss: (() -> Void)?
    public var onLogout: (() -> Void)?
    public var onGoToItems: (() -> Void)?

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

    public init(profile: UserProfile = .demo) {
        self.userName = profile.name
        self.userEmail = profile.email
        self.userBio = profile.bio
        self.viewCount = profile.viewsCount
        self.favoritesCount = profile.favoritesCount
        self.daysCount = profile.daysCount
    }

    // MARK: - Actions

    public func didTapGoToItems() {
        logger.log("Go to Items tapped from Profile")
        onGoToItems?()
    }

    public func didTapDismiss() {
        onDismiss?()
    }

    public func logout() {
        logger.log("User tapped logout from Profile", level: .info, category: .general)
        onLogout?()
    }
}
