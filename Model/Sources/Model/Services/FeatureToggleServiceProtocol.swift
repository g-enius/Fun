//
//  FeatureToggleServiceProtocol.swift
//  Model
//
//  Protocol for feature toggle service
//

import Combine
import Foundation

@MainActor
public protocol FeatureToggleServiceProtocol: AnyObject {
    var featuredCarousel: Bool { get set }
    var simulateErrors: Bool { get set }
    var aiSummary: Bool { get set }
    var appearanceMode: AppearanceMode { get set }

    var featuredCarouselPublisher: AnyPublisher<Bool, Never> { get }
    var simulateErrorsPublisher: AnyPublisher<Bool, Never> { get }
    var aiSummaryPublisher: AnyPublisher<Bool, Never> { get }
    var appearanceModePublisher: AnyPublisher<AppearanceMode, Never> { get }
}
