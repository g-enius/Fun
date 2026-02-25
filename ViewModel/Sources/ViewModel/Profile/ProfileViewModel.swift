//
//  ProfileViewModel.swift
//  ViewModel
//
//  ViewModel for Profile screen
//

import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class ProfileViewModel {

    // MARK: - Navigation Closures

    public var onDismiss: (() -> Void)?
    public var onLogout: (() -> Void)?
    public var onGoToItems: (() -> Void)?

    // MARK: - Services

    @ObservationIgnored @Service(.logger) private var logger: LoggerService

    // MARK: - State

    public var userName: String
    public var userEmail: String
    public var userBio: String
    public var viewCount: Int
    public var favoritesCount: Int
    public var daysCount: Int

    // MARK: - Initialization

    public init(
        onDismiss: (() -> Void)? = nil,
        onLogout: (() -> Void)? = nil,
        onGoToItems: (() -> Void)? = nil,
        profile: UserProfile = .demo
    ) {
        self.onDismiss = onDismiss
        self.onLogout = onLogout
        self.onGoToItems = onGoToItems
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
