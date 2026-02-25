//
//  DefaultFeatureToggleService.swift
//  Services
//
//  Default implementation of FeatureToggleServiceProtocol
//

import Foundation

import FunCore
import FunModel

@MainActor
public final class DefaultFeatureToggleService: FeatureToggleServiceProtocol {

    // MARK: - Feature Toggles

    public var featuredCarousel: Bool {
        didSet {
            UserDefaults.standard.set(featuredCarousel, forKey: .featureCarousel)
            carouselBroadcaster.yield(featuredCarousel)
        }
    }

    public var simulateErrors: Bool {
        didSet {
            UserDefaults.standard.set(simulateErrors, forKey: .simulateErrors)
        }
    }

    public var aiSummary: Bool {
        didSet {
            UserDefaults.standard.set(aiSummary, forKey: .aiSummary)
        }
    }

    public var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: .appearanceMode)
            appearanceBroadcaster.yield(appearanceMode)
        }
    }

    // MARK: - Streams

    private let carouselBroadcaster = StreamBroadcaster<Bool>()
    private let appearanceBroadcaster = StreamBroadcaster<AppearanceMode>()

    public var featuredCarouselChanges: AsyncStream<Bool> {
        carouselBroadcaster.makeStream()
    }

    public var appearanceModeChanges: AsyncStream<AppearanceMode> {
        appearanceBroadcaster.makeStream()
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
