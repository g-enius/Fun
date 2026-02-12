//
//  HomeTabBarViewModel.swift
//  ViewModel
//
//  ViewModel for tab bar tab switching
//

import Combine
import Foundation

import FunCore
import FunModel

@MainActor
public class HomeTabBarViewModel: ObservableObject {

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService

    // MARK: - Published State

    /// Currently selected tab index
    @Published public var selectedTabIndex: Int = 0

    // MARK: - Initialization

    public init() {
        logger.log("HomeTabBarViewModel initialized")
    }

    // MARK: - Tab Management

    /// Called when tab selection changes
    public func tabDidChange(to index: Int) {
        guard (0..<TabIndex.allCases.count).contains(index) else {
            logger.log("Invalid tab index: \(index)", level: .warning, category: .general)
            return
        }
        selectedTabIndex = index
        logger.log("Tab switched to index: \(index)")
    }

    /// Switch to a specific tab programmatically
    public func switchToTab(_ index: Int) {
        guard (0..<TabIndex.allCases.count).contains(index) else {
            logger.log("Invalid tab index: \(index)", level: .warning, category: .general)
            return
        }
        selectedTabIndex = index
        logger.log("Programmatically switched to tab index: \(index)")
    }
}
