//
//  DetailViewModel.swift
//  ViewModel
//
//  ViewModel for Detail screen
//

import Combine
import Foundation

import FunCore
import FunModel

@MainActor
public class DetailViewModel: ObservableObject {

    // MARK: - Navigation Closures

    public var onPop: (() -> Void)?
    public var onShare: ((String) -> Void)?

    // MARK: - Services

    private let logger: LoggerService
    private let favoritesService: FavoritesServiceProtocol
    private let aiService: AIServiceProtocol
    private let featureToggleService: FeatureToggleServiceProtocol

    // MARK: - Published State

    @Published public var itemTitle: String
    @Published public var category: String
    @Published public var itemDescription: String
    @Published public var isFavorited: Bool = false
    @Published public var summary: String = ""
    @Published public var isSummarizing: Bool = false
    @Published public var summaryError: String = ""

    public var showAISummary: Bool {
        featureToggleService.aiSummary && aiService.isAvailable
    }

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var itemId: String

    // MARK: - Initialization

    public init(item: FeaturedItem, serviceLocator: ServiceLocator = .shared) {
        self.logger = serviceLocator.resolve(for: .logger)
        self.favoritesService = serviceLocator.resolve(for: .favorites)
        self.aiService = serviceLocator.resolve(for: .ai)
        self.featureToggleService = serviceLocator.resolve(for: .featureToggles)

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

    /// Called when the view controller is removed from the navigation stack by the system (back button)
    public func handleBackNavigation() {
        onPop?()
    }

    public func didTapShare() {
        let shareText = L10n.Detail.shareText(itemTitle)
        onShare?(shareText)
    }

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
