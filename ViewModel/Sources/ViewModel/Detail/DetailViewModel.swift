//
//  DetailViewModel.swift
//  ViewModel
//
//  ViewModel for Detail screen
//

import Combine
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

    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
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

    // MARK: - Setup

    private func observeFavoritesChanges() {
        favoritesService.favoritesDidChange
            .sink { [weak self] favorites in
                guard let self else { return }
                self.isFavorited = favorites.contains(self.itemId)
            }
            .store(in: &cancellables)
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
