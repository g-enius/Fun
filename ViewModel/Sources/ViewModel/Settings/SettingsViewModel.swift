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

    @Published public var isDarkModeEnabled: Bool = false {
        didSet {
            guard isInitialized else { return }
            featureToggleService.darkModeEnabled = isDarkModeEnabled
        }
    }

    @Published public var featuredCarouselEnabled: Bool = false {
        didSet {
            guard isInitialized else { return }
            featureToggleService.featuredCarousel = featuredCarouselEnabled
        }
    }

    @Published public var simulateErrorsEnabled: Bool = false {
        didSet {
            guard isInitialized else { return }
            featureToggleService.simulateErrors = simulateErrorsEnabled
        }
    }

    private var isInitialized = false

    // MARK: - Initialization

    public init(coordinator: SettingsCoordinator?) {
        self.coordinator = coordinator
        self.isDarkModeEnabled = featureToggleService.darkModeEnabled
        self.featuredCarouselEnabled = featureToggleService.featuredCarousel
        self.simulateErrorsEnabled = featureToggleService.simulateErrors
        self.isInitialized = true
    }

    // MARK: - Actions

    public func resetDarkMode() {
        isDarkModeEnabled = false
        logger.log("Dark mode reset")
    }

    public func resetFeatureToggles() {
        featuredCarouselEnabled = true
        simulateErrorsEnabled = false
        logger.log("Feature toggles reset")
    }
}
