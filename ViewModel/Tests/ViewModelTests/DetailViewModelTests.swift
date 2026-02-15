//
//  DetailViewModelTests.swift
//  ViewModel
//
//  Unit tests for DetailViewModel
//

import Testing
import Foundation
@testable import FunViewModel
@testable import FunModel
@testable import FunCore
import FunModelTestSupport

@Suite("DetailViewModel Tests", .serialized)
@MainActor
struct DetailViewModelTests {

    // MARK: - Setup

    private func setupServices(
        initialFavorites: Set<String> = [],
        aiService: MockAIService = MockAIService(),
        featureToggleService: MockFeatureToggleService = MockFeatureToggleService()
    ) {
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        ServiceLocator.shared.register(featureToggleService, for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
        ServiceLocator.shared.register(aiService, for: .ai)
    }

    private var testItem: FeaturedItem {
        FeaturedItem.asyncAwait
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches item data")
    func testInitialStateMatchesItem() async {
        setupServices()
        let item = testItem
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.itemTitle == item.title)
        #expect(viewModel.category == item.category)
        #expect(viewModel.itemDescription == TechnologyDescriptions.description(for: item.id))
    }

    @Test("isFavorited is true when item is in favorites")
    func testIsFavoritedTrue() async {
        let item = testItem
        setupServices(initialFavorites: [item.id])
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.isFavorited == true)
    }

    @Test("isFavorited is false when item is not in favorites")
    func testIsFavoritedFalse() async {
        setupServices(initialFavorites: [])
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.isFavorited == false)
    }

    // MARK: - Toggle Favorite Tests

    @Test("didTapToggleFavorite adds item to favorites")
    func testToggleFavoriteAdds() async {
        setupServices(initialFavorites: [])
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.isFavorited == false)

        viewModel.didTapToggleFavorite()

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.isFavorited == true)
    }

    @Test("didTapToggleFavorite removes item from favorites")
    func testToggleFavoriteRemoves() async {
        let item = testItem
        setupServices(initialFavorites: [item.id])
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.isFavorited == true)

        viewModel.didTapToggleFavorite()

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.isFavorited == false)
    }

    // MARK: - Favorites Observation Tests

    @Test("ViewModel updates when favorites service changes externally")
    func testExternalFavoritesChange() async {
        setupServices(initialFavorites: [])
        let mockFavorites = MockFavoritesService(initialFavorites: [])
        ServiceLocator.shared.register(mockFavorites, for: .favorites)

        let item = testItem
        let viewModel = DetailViewModel(item: item, coordinator: nil)

        #expect(viewModel.isFavorited == false)

        // Change favorites externally
        mockFavorites.addFavorite(item.id)

        // Wait for publisher
        await Task.yield()

        #expect(viewModel.isFavorited == true)
    }

    // MARK: - Share Tests

    @Test("didTapShare calls coordinator share")
    func testDidTapShareCallsCoordinator() async {
        setupServices()
        let coordinator = MockDetailCoordinator()
        let viewModel = DetailViewModel(item: testItem, coordinator: coordinator)

        viewModel.didTapShare()

        #expect(coordinator.shareCalled == true)
        #expect(coordinator.lastShareText != nil)
        #expect(coordinator.lastShareText?.contains(testItem.title) == true)
    }

    // MARK: - Back Navigation Tests

    @Test("handleBackNavigation calls coordinator didPop")
    func testHandleBackNavigationCallsCoordinator() async {
        setupServices()
        let coordinator = MockDetailCoordinator()
        let viewModel = DetailViewModel(item: testItem, coordinator: coordinator)

        viewModel.handleBackNavigation()

        #expect(coordinator.didPopCalled == true)
    }

    @Test("handleBackNavigation with nil coordinator does not crash")
    func testHandleBackNavigationWithNilCoordinator() async {
        setupServices()
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        viewModel.handleBackNavigation() // Should not crash
    }

    // MARK: - Different Items Tests

    @Test("Works with different featured items")
    func testDifferentItems() async {
        setupServices()

        let items: [FeaturedItem] = [.swiftUI, .combine, .mvvm, .coordinator]
        for item in items {
            let viewModel = DetailViewModel(item: item, coordinator: nil)
            #expect(viewModel.itemTitle == item.title)
            #expect(viewModel.category == item.category)
        }
    }

    // MARK: - AI Summary Tests

    @Test("showAISummary is true when toggle on and AI available")
    func testShowAISummaryTrue() async {
        let aiService = MockAIService(isAvailable: true)
        let featureToggle = MockFeatureToggleService(aiSummary: true)
        setupServices(aiService: aiService, featureToggleService: featureToggle)
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.showAISummary == true)
    }

    @Test("showAISummary is false when toggle off")
    func testShowAISummaryFalseWhenToggleOff() async {
        let aiService = MockAIService(isAvailable: true)
        let featureToggle = MockFeatureToggleService(aiSummary: false)
        setupServices(aiService: aiService, featureToggleService: featureToggle)
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.showAISummary == false)
    }

    @Test("showAISummary is false when AI unavailable")
    func testShowAISummaryFalseWhenUnavailable() async {
        let aiService = MockAIService(isAvailable: false)
        let featureToggle = MockFeatureToggleService(aiSummary: true)
        setupServices(aiService: aiService, featureToggleService: featureToggle)
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.showAISummary == false)
    }

    @Test("generateSummary sets summary text")
    func testGenerateSummarySetsText() async {
        let aiService = MockAIService(stubbedSummary: "Test summary result")
        setupServices(aiService: aiService)
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        await viewModel.generateSummary()

        #expect(viewModel.summary == "Test summary result")
        #expect(viewModel.summaryError.isEmpty)
        #expect(viewModel.isSummarizing == false)
        #expect(aiService.summarizeCallCount == 1)
    }

    @Test("generateSummary handles errors")
    func testGenerateSummaryHandlesErrors() async {
        let aiService = MockAIService(shouldThrowError: true)
        setupServices(aiService: aiService)
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        await viewModel.generateSummary()

        #expect(viewModel.summary.isEmpty)
        #expect(!viewModel.summaryError.isEmpty)
        #expect(viewModel.isSummarizing == false)
    }

    @Test("isSummarizing is false after generation completes")
    func testIsSummarizingStateAfterCompletion() async {
        let aiService = MockAIService(stubbedSummary: "Summary")
        setupServices(aiService: aiService)
        let viewModel = DetailViewModel(item: testItem, coordinator: nil)

        #expect(viewModel.isSummarizing == false)

        await viewModel.generateSummary()

        #expect(viewModel.isSummarizing == false)
    }
}
