//
//  MockFeatureToggleService.swift
//  Model
//
//  Mock implementation of FeatureToggleServiceProtocol for testing
//

import FunCore
import FunModel

@MainActor
public final class MockFeatureToggleService: FeatureToggleServiceProtocol {

    public var featuredCarousel: Bool {
        didSet {
            guard featuredCarousel != oldValue else { return }
            carouselBroadcaster.yield(featuredCarousel)
        }
    }
    public var simulateErrors: Bool
    public var aiSummary: Bool
    public var appearanceMode: AppearanceMode {
        didSet {
            guard appearanceMode != oldValue else { return }
            appearanceBroadcaster.yield(appearanceMode)
        }
    }

    private let carouselBroadcaster = StreamBroadcaster<Bool>()
    private let appearanceBroadcaster = StreamBroadcaster<AppearanceMode>()

    public var featuredCarouselStream: AsyncStream<Bool> {
        carouselBroadcaster.makeStream()
    }

    public var appearanceModeStream: AsyncStream<AppearanceMode> {
        appearanceBroadcaster.makeStream()
    }

    public init(featuredCarousel: Bool = true, simulateErrors: Bool = false, aiSummary: Bool = true, appearanceMode: AppearanceMode = .system) {
        self.featuredCarousel = featuredCarousel
        self.simulateErrors = simulateErrors
        self.aiSummary = aiSummary
        self.appearanceMode = appearanceMode
    }
}
