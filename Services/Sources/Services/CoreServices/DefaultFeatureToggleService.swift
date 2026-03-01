//
//  DefaultFeatureToggleService.swift
//  Services
//
//  Default implementation of FeatureToggleServiceProtocol
//

import Combine
import Foundation

import FunModel

@MainActor
public final class DefaultFeatureToggleService: FeatureToggleServiceProtocol {

    // MARK: - Feature Toggles

    @Published public var featuredCarousel: Bool {
        didSet { UserDefaults.standard.set(featuredCarousel, forKey: .featureCarousel) }
    }
    @Published public var simulateErrors: Bool {
        didSet { UserDefaults.standard.set(simulateErrors, forKey: .simulateErrors) }
    }
    @Published public var aiSummary: Bool {
        didSet { UserDefaults.standard.set(aiSummary, forKey: .aiSummary) }
    }
    @Published public var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: .appearanceMode) }
    }

    // MARK: - Publishers

    public var featuredCarouselPublisher: AnyPublisher<Bool, Never> {
        $featuredCarousel.removeDuplicates().eraseToAnyPublisher()
    }

    public var appearanceModePublisher: AnyPublisher<AppearanceMode, Never> {
        $appearanceMode.removeDuplicates().eraseToAnyPublisher()
    }

    // MARK: - Initialization

    public init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
            UserDefaultsKey.featureCarousel.rawValue: true,
            UserDefaultsKey.simulateErrors.rawValue: false,
            UserDefaultsKey.aiSummary.rawValue: true,
            UserDefaultsKey.appearanceMode.rawValue: AppearanceMode.system.rawValue
        ])

        featuredCarousel = defaults.bool(forKey: .featureCarousel)
        simulateErrors = defaults.bool(forKey: .simulateErrors)
        aiSummary = defaults.bool(forKey: .aiSummary)
        appearanceMode = defaults.string(forKey: .appearanceMode)
            .flatMap(AppearanceMode.init) ?? .system
    }
}
