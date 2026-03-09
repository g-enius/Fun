//
//  FeatureToggleServiceProtocol.swift
//  Model
//
//  Protocol for feature toggle service
//

import Foundation

@MainActor
public protocol FeatureToggleServiceProtocol: AnyObject {
    var featuredCarousel: Bool { get set }
    var simulateErrors: Bool { get set }
    var aiSummary: Bool { get set }
    var appearanceMode: AppearanceMode { get set }

    var featuredCarouselStream: AsyncStream<Bool> { get }
    var appearanceModeStream: AsyncStream<AppearanceMode> { get }
}
