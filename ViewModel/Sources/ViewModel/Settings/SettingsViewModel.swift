//
//  SettingsViewModel.swift
//  ViewModel
//
//  ViewModel for Settings screen
//

import Combine
import Foundation

import FunCore
import FunModel

@MainActor
public class SettingsViewModel: ObservableObject {

    // MARK: - Coordinator

    private weak var coordinator: SettingsCoordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
    @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - Published State

    @Published public var appearanceMode: AppearanceMode = .system {
        didSet { featureToggleService.appearanceMode = appearanceMode }
    }

    @Published public var featuredCarouselEnabled: Bool = false {
        didSet { featureToggleService.featuredCarousel = featuredCarouselEnabled }
    }

    @Published public var simulateErrorsEnabled: Bool = false {
        didSet { featureToggleService.simulateErrors = simulateErrorsEnabled }
    }

    @Published public var aiSummaryEnabled: Bool = true {
        didSet { featureToggleService.aiSummary = aiSummaryEnabled }
    }

    // MARK: - Initialization

    public init(coordinator: SettingsCoordinator?) {
        self.coordinator = coordinator
        _appearanceMode = Published(initialValue: featureToggleService.appearanceMode)
        _featuredCarouselEnabled = Published(initialValue: featureToggleService.featuredCarousel)
        _simulateErrorsEnabled = Published(initialValue: featureToggleService.simulateErrors)
        _aiSummaryEnabled = Published(initialValue: featureToggleService.aiSummary)
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
