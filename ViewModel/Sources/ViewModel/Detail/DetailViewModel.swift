//
//  DetailViewModel.swift
//  ViewModel
//
//  ViewModel for Detail screen
//

import Foundation
import Observation

import FunCore
import FunModel

@MainActor
@Observable
public class DetailViewModel: SessionProvider {

    // MARK: - DI

    public let session: Session
    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored @Service(.favorites) private var favoritesService: FavoritesServiceProtocol
    @ObservationIgnored @Service(.ai) private var aiService: AIServiceProtocol
    @ObservationIgnored @Service(.featureToggles) private var featureToggleService: FeatureToggleServiceProtocol

    // MARK: - State

    public var itemTitle: String
    public var category: String
    public var itemDescription: String
    public var isFavorited: Bool = false
    public var summary: String = ""
    public var isSummarizing: Bool = false
    public var summaryError: String = ""

    public var showAISummary: Bool {
        featureToggleService.aiSummary && aiService.isAvailable
    }

    /// Text to share via share sheet
    public var shareText: String {
        L10n.Detail.shareText(itemTitle)
    }

    // MARK: - Private Properties

    @ObservationIgnored private var favoritesObservation: Task<Void, Never>?
    @ObservationIgnored private var itemId: String

    // MARK: - Initialization

    public init(item: FeaturedItem, session: Session) {
        self.session = session

        self.itemTitle = item.title
        self.category = item.category
        self.itemId = item.id
        self.itemDescription = TechnologyDescriptions.description(for: item.id)
        self.isFavorited = favoritesService.isFavorited(itemId)
        observeFavoritesChanges()
    }

    deinit {
        favoritesObservation?.cancel()
    }

    // MARK: - Setup

    private func observeFavoritesChanges() {
        let stream = favoritesService.favoritesStream
        let itemId = self.itemId
        favoritesObservation = Task { [weak self] in
            for await favorites in stream {
                guard let self else { break }
                self.isFavorited = favorites.contains(itemId)
            }
        }
    }

    // MARK: - Actions

    public func didTapToggleFavorite() {
        favoritesService.toggleFavorite(itemId)
        logger.log("Favorite toggled for \(itemTitle)")
    }

    public func generateSummary() async {
        isSummarizing = true
        summaryError = ""
        do {
            summary = try await aiService.summarize(itemDescription)
        } catch {
            summaryError = L10n.Detail.summaryFailed
            logger.log("AI summary failed: \(error.localizedDescription)")
        }
        isSummarizing = false
    }
}
