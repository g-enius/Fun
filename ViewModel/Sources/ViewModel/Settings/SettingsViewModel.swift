//
//  SettingsViewModel.swift
//  ViewModel
//
//  ViewModel for Settings screen
//

import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class SettingsViewModel {

    // MARK: - Services

    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - State

    public var appearanceMode: AppearanceMode = .system {
        didSet { featureToggleService.appearanceMode = appearanceMode }
    }

    public var featuredCarouselEnabled: Bool = true {
        didSet { featureToggleService.featuredCarousel = featuredCarouselEnabled }
    }

    public var simulateErrorsEnabled: Bool = false {
        didSet { featureToggleService.simulateErrors = simulateErrorsEnabled }
    }

    public var aiSummaryEnabled: Bool = true {
        didSet { featureToggleService.aiSummary = aiSummaryEnabled }
    }

    // MARK: - Initialization

    public init() {
        // Override defaults with actual service values (didSet won't fire during init)
        appearanceMode = featureToggleService.appearanceMode
        featuredCarouselEnabled = featureToggleService.featuredCarousel
        simulateErrorsEnabled = featureToggleService.simulateErrors
        aiSummaryEnabled = featureToggleService.aiSummary
    }

    // MARK: - Actions

    public func resetAppearance() {
        appearanceMode = .system
        logger.log("Appearance mode reset to system")
    }

    public func resetFeatureToggles() {
        featuredCarouselEnabled = true
        simulateErrorsEnabled = false
        aiSummaryEnabled = true
        logger.log("Feature toggles reset")
    }
}
