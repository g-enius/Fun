//
//  Tab5ViewModel.swift
//  ViewModel
//
//  ViewModel for Tab5 (Settings) screen
//

import Foundation
import Combine
import FunModel
import FunToolbox

@MainActor
public class Tab5ViewModel: ObservableObject {

    // MARK: - Coordinator

    private weak var coordinator: Tab5Coordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService

    // We need direct access to the service for mutations
    private var featureToggleService: FeatureToggleServiceProtocol {
        ServiceLocator.shared.resolve(for: .featureToggles)
    }

    // MARK: - Published State

    @Published public var isDarkModeEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(isDarkModeEnabled, forKey: .darkModeEnabled)
            NotificationCenter.default.post(name: .appSettingsDidChange, object: nil)
        }
    }

    @Published public var featuredCarouselEnabled: Bool = false {
        didSet { featureToggleService.featuredCarousel = featuredCarouselEnabled }
    }

    @Published public var analyticsEnabled: Bool = false {
        didSet {
            featureToggleService.featureAnalytics = analyticsEnabled
            logger.log("Analytics \(analyticsEnabled ? "enabled" : "disabled")")
        }
    }

    @Published public var debugModeEnabled: Bool = false {
        didSet {
            featureToggleService.featureDebugMode = debugModeEnabled
            logger.log("Debug mode \(debugModeEnabled ? "enabled" : "disabled")")
        }
    }

    // MARK: - Initialization

    public init(coordinator: Tab5Coordinator?) {
        self.coordinator = coordinator
        self.isDarkModeEnabled = UserDefaults.standard.bool(forKey: .darkModeEnabled)
        self.featuredCarouselEnabled = featureToggleService.featuredCarousel
        self.analyticsEnabled = featureToggleService.featureAnalytics
        self.debugModeEnabled = featureToggleService.featureDebugMode
    }

    // MARK: - Actions

    public func resetDarkMode() {
        isDarkModeEnabled = false
        logger.log("Dark mode reset")
    }

    public func resetFeatureToggles() {
        featuredCarouselEnabled = true
        analyticsEnabled = false
        debugModeEnabled = false
        logger.log("Feature toggles reset")
    }
}
