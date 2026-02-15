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

    @Published public var featuredCarousel: Bool
    @Published public var simulateErrors: Bool
    @Published public var aiSummary: Bool
    @Published public var appearanceMode: AppearanceMode

    // MARK: - Publishers

    public var featuredCarouselPublisher: AnyPublisher<Bool, Never> {
        $featuredCarousel.removeDuplicates().eraseToAnyPublisher()
    }

    public var simulateErrorsPublisher: AnyPublisher<Bool, Never> {
        $simulateErrors.removeDuplicates().eraseToAnyPublisher()
    }

    public var aiSummaryPublisher: AnyPublisher<Bool, Never> {
        $aiSummary.removeDuplicates().eraseToAnyPublisher()
    }

    public var appearanceModePublisher: AnyPublisher<AppearanceMode, Never> {
        $appearanceMode.removeDuplicates().eraseToAnyPublisher()
    }

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

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

        // Persist changes back to UserDefaults
        $featuredCarousel.dropFirst().sink {
            UserDefaults.standard.set($0, forKey: .featureCarousel)
        }.store(in: &cancellables)

        $simulateErrors.dropFirst().sink {
            UserDefaults.standard.set($0, forKey: .simulateErrors)
        }.store(in: &cancellables)

        $aiSummary.dropFirst().sink {
            UserDefaults.standard.set($0, forKey: .aiSummary)
        }.store(in: &cancellables)

        $appearanceMode.dropFirst().sink {
            UserDefaults.standard.set($0.rawValue, forKey: .appearanceMode)
        }.store(in: &cancellables)
    }
}
