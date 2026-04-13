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
public class ProfileViewModel: SessionProvider {

    // MARK: - Navigation Closures

    @ObservationIgnored public var onDismiss: (() -> Void)?
    @ObservationIgnored public var onLogout: (() -> Void)?
    @ObservationIgnored public var onGoToItems: (() -> Void)?

    // MARK: - DI

    public let session: Session
    @ObservationIgnored @Service(.logger) private var logger: LoggerService

    // MARK: - State

    public var userName: String
    public var userEmail: String
    public var userBio: String
    public var viewCount: Int
    public var favoritesCount: Int
    public var daysCount: Int

    // MARK: - Initialization

    public init(profile: UserProfile = .demo, session: Session) {
        self.session = session
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
