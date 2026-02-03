//
//  UserProfile.swift
//  Model
//
//  User profile data model
//

import Foundation

public struct UserProfile: Equatable, Sendable {
    public let name: String
    public let email: String
    public let bio: String
    public let viewsCount: Int
    public let favoritesCount: Int
    public let daysCount: Int

    public init(
        name: String = "Demo User",
        email: String = "demo@example.com",
        bio: String = "iOS Developer passionate about clean architecture and modern Swift patterns.",
        viewsCount: Int = 1234,
        favoritesCount: Int = 56,
        daysCount: Int = 42
    ) {
        self.name = name
        self.email = email
        self.bio = bio
        self.viewsCount = viewsCount
        self.favoritesCount = favoritesCount
        self.daysCount = daysCount
    }
}

public extension UserProfile {
    static let demo = UserProfile()
}
