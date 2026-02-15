//
//  MockFeatureToggleService.swift
//  Model
//
//  Mock implementation of FeatureToggleServiceProtocol for testing
//

import Combine
import FunModel

@MainActor
public final class MockFeatureToggleService: FeatureToggleServiceProtocol {

    @Published public var featuredCarousel: Bool
    @Published public var simulateErrors: Bool
    @Published public var aiSummary: Bool
    @Published public var appearanceMode: AppearanceMode

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

    public init(featuredCarousel: Bool = true, simulateErrors: Bool = false, aiSummary: Bool = true, appearanceMode: AppearanceMode = .system) {
        self.featuredCarousel = featuredCarousel
        self.simulateErrors = simulateErrors
        self.aiSummary = aiSummary
        self.appearanceMode = appearanceMode
    }
}
