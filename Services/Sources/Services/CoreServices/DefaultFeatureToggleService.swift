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
    @Published public var darkModeEnabled: Bool

    // MARK: - Publishers

    public var featuredCarouselPublisher: AnyPublisher<Bool, Never> {
        $featuredCarousel.removeDuplicates().eraseToAnyPublisher()
    }

    public var simulateErrorsPublisher: AnyPublisher<Bool, Never> {
        $simulateErrors.removeDuplicates().eraseToAnyPublisher()
    }

    public var darkModePublisher: AnyPublisher<Bool, Never> {
        $darkModeEnabled.removeDuplicates().eraseToAnyPublisher()
    }

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init() {
        // Load from UserDefaults (with defaults for first launch)
        let defaults = UserDefaults.standard
        if defaults.object(forKey: .featureCarousel) == nil {
            defaults.set(true, forKey: .featureCarousel)
        }
        if defaults.object(forKey: .simulateErrors) == nil {
            defaults.set(false, forKey: .simulateErrors)
        }
        if defaults.object(forKey: .darkModeEnabled) == nil {
            defaults.set(false, forKey: .darkModeEnabled)
        }

        featuredCarousel = defaults.bool(forKey: .featureCarousel)
        simulateErrors = defaults.bool(forKey: .simulateErrors)
        darkModeEnabled = defaults.bool(forKey: .darkModeEnabled)

        // Persist changes back to UserDefaults
        $featuredCarousel.dropFirst().sink {
            UserDefaults.standard.set($0, forKey: .featureCarousel)
        }.store(in: &cancellables)

        $simulateErrors.dropFirst().sink {
            UserDefaults.standard.set($0, forKey: .simulateErrors)
        }.store(in: &cancellables)

        $darkModeEnabled.dropFirst().sink {
            UserDefaults.standard.set($0, forKey: .darkModeEnabled)
        }.store(in: &cancellables)
    }
}
