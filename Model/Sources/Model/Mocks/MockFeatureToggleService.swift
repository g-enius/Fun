//
//  MockFeatureToggleService.swift
//  Model
//
//  Mock implementation of FeatureToggleServiceProtocol for testing
//

import Foundation
import Combine

@MainActor
public final class MockFeatureToggleService: FeatureToggleServiceProtocol {

    private let togglesChangedSubject = PassthroughSubject<Void, Never>()

    public var featureTogglesDidChange: AnyPublisher<Void, Never> {
        togglesChangedSubject.eraseToAnyPublisher()
    }

    public var featuredCarousel: Bool {
        didSet { togglesChangedSubject.send() }
    }

    public var simulateErrors: Bool {
        didSet { togglesChangedSubject.send() }
    }

    public var darkModeEnabled: Bool {
        didSet { togglesChangedSubject.send() }
    }

    public init(featuredCarousel: Bool = true, simulateErrors: Bool = false, darkModeEnabled: Bool = false) {
        self.featuredCarousel = featuredCarousel
        self.simulateErrors = simulateErrors
        self.darkModeEnabled = darkModeEnabled
    }
}
