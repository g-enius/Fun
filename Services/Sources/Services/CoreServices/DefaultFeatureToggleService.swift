//
//  DefaultFeatureToggleService.swift
//  Services
//
//  Default implementation of FeatureToggleServiceProtocol
//

import Foundation
import Combine
import FunModel

@MainActor
public final class DefaultFeatureToggleService: FeatureToggleServiceProtocol {

    // MARK: - Combine Publisher

    private let togglesChangedSubject = PassthroughSubject<Void, Never>()

    public var featureTogglesDidChange: AnyPublisher<Void, Never> {
        togglesChangedSubject.eraseToAnyPublisher()
    }

    // MARK: - Feature Toggles

    public var featuredCarousel: Bool {
        get { UserDefaults.standard.bool(forKey: .featureCarousel) }
        set {
            UserDefaults.standard.set(newValue, forKey: .featureCarousel)
            togglesChangedSubject.send()
        }
    }

    public var simulateErrors: Bool {
        get { UserDefaults.standard.bool(forKey: .simulateErrors) }
        set {
            UserDefaults.standard.set(newValue, forKey: .simulateErrors)
            togglesChangedSubject.send()
        }
    }

    public var darkModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: .darkModeEnabled) }
        set {
            UserDefaults.standard.set(newValue, forKey: .darkModeEnabled)
            togglesChangedSubject.send()
        }
    }

    // MARK: - Initialization

    public init() {
        if UserDefaults.standard.object(forKey: .featureCarousel) == nil {
            UserDefaults.standard.set(true, forKey: .featureCarousel)
        }
        if UserDefaults.standard.object(forKey: .simulateErrors) == nil {
            UserDefaults.standard.set(false, forKey: .simulateErrors)
        }
        if UserDefaults.standard.object(forKey: .darkModeEnabled) == nil {
            UserDefaults.standard.set(false, forKey: .darkModeEnabled)
        }
    }
}
