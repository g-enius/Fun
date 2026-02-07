//
//  FeatureToggleServiceProtocol.swift
//  Model
//
//  Protocol for feature toggle service
//

import Foundation
import Combine

@MainActor
public protocol FeatureToggleServiceProtocol: AnyObject {
    var featuredCarousel: Bool { get set }
    var simulateErrors: Bool { get set }
    var darkModeEnabled: Bool { get set }

    /// Publisher that emits when any feature toggle changes
    var featureTogglesDidChange: AnyPublisher<Void, Never> { get }
}
