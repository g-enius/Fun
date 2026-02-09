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

    // MARK: - Coordinator

    private weak var coordinator: DetailCoordinator?

    // MARK: - Services

    @Service(.logger) private var logger: LoggerService
    @Service(.favorites) private var favoritesService: FavoritesServiceProtocol

    // MARK: - Published State

    @Published public var itemTitle: String
    @Published public var category: String
    @Published public var itemDescription: String
    @Published public var isFavorited: Bool = false

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private var itemId: String

    // MARK: - Initialization

    public init(item: FeaturedItem, coordinator: DetailCoordinator?) {
        self.itemTitle = item.title
        self.category = item.category
        self.itemId = item.id
        self.itemDescription = TechnologyDescriptions.description(for: item.id)
        self.coordinator = coordinator
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
        coordinator?.didPop()
    }

    public func didTapShare() {
        let shareText = L10n.Detail.shareText(itemTitle)
        coordinator?.share(text: shareText)
    }

    public func didTapToggleFavorite() {
        favoritesService.toggleFavorite(itemId)
        logger.log("Favorite toggled for \(itemTitle)")
    }
}
