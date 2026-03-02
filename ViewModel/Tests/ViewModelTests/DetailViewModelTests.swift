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

extension ViewModelTestSuite {

@Suite("DetailViewModel Tests")
@MainActor
struct DetailViewModelTests {

    // MARK: - Setup

<<<<<<< HEAD
    private func makeServiceLocator(
        initialFavorites: Set<String> = [],
        aiService: MockAIService = MockAIService(),
        featureToggleService: MockFeatureToggleService = MockFeatureToggleService()
    ) -> ServiceLocator {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        locator.register(featureToggleService, for: .featureToggles)
        locator.register(MockToastService(), for: .toast)
        locator.register(aiService, for: .ai)
        return locator
=======
    @discardableResult
    private func setupServices(
        initialFavorites: Set<String> = [],
        aiService: MockAIService = MockAIService(),
        featureToggleService: MockFeatureToggleService = MockFeatureToggleService()
    ) -> MockFavoritesService {
        let favoritesService = MockFavoritesService(initialFavorites: initialFavorites)
        ServiceLocator.shared.reset()
        ServiceLocator.shared.register(MockLoggerService(), for: .logger)
        ServiceLocator.shared.register(MockNetworkService(), for: .network)
        ServiceLocator.shared.register(favoritesService, for: .favorites)
        ServiceLocator.shared.register(featureToggleService, for: .featureToggles)
        ServiceLocator.shared.register(MockToastService(), for: .toast)
        ServiceLocator.shared.register(aiService, for: .ai)
        return favoritesService
>>>>>>> 532c2b7 (Add oldValue guards, fix tests, fix lint)
    }

    private var testItem: FeaturedItem {
        FeaturedItem.asyncAwait
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches item data")
    func testInitialStateMatchesItem() async {
        let item = testItem
        let viewModel = DetailViewModel(item: item, serviceLocator: makeServiceLocator())

        #expect(viewModel.itemTitle == item.title)
        #expect(viewModel.category == item.category)
        #expect(viewModel.itemDescription == TechnologyDescriptions.description(for: item.id))
    }

    @Test("isFavorited is true when item is in favorites")
    func testIsFavoritedTrue() async {
        let item = testItem
        let viewModel = DetailViewModel(item: item, serviceLocator: makeServiceLocator(initialFavorites: [item.id]))

        #expect(viewModel.isFavorited == true)
    }

    @Test("isFavorited is false when item is not in favorites")
    func testIsFavoritedFalse() async {
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(initialFavorites: []))

        #expect(viewModel.isFavorited == false)
    }

    // MARK: - Toggle Favorite Tests

    @Test("didTapToggleFavorite adds item to favorites")
    func testToggleFavoriteAdds() async {
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(initialFavorites: []))

        #expect(viewModel.isFavorited == false)

        viewModel.didTapToggleFavorite()
        await awaitObservation { _ = viewModel.isFavorited }

        #expect(viewModel.isFavorited == true)
    }

    @Test("didTapToggleFavorite removes item from favorites")
    func testToggleFavoriteRemoves() async {
        let item = testItem
        let viewModel = DetailViewModel(item: item, serviceLocator: makeServiceLocator(initialFavorites: [item.id]))

        #expect(viewModel.isFavorited == true)

        viewModel.didTapToggleFavorite()
        await awaitObservation { _ = viewModel.isFavorited }

        #expect(viewModel.isFavorited == false)
    }

    // MARK: - Favorites Observation Tests

    @Test("ViewModel updates when favorites service changes externally")
    func testExternalFavoritesChange() async {
        let mockFavorites = MockFavoritesService(initialFavorites: [])
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(mockFavorites, for: .favorites)
        locator.register(MockFeatureToggleService(), for: .featureToggles)
        locator.register(MockToastService(), for: .toast)
        locator.register(MockAIService(), for: .ai)

        let item = testItem
        let viewModel = DetailViewModel(item: item, serviceLocator: locator)

        #expect(viewModel.isFavorited == false)

        mockFavorites.addFavorite(item.id)
        await awaitObservation { _ = viewModel.isFavorited }

        #expect(viewModel.isFavorited == true)
    }

    // MARK: - Share Text Tests

    @Test("shareText contains item title")
    func testShareTextContainsItemTitle() async {
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator())

        #expect(viewModel.shareText.contains(testItem.title))
    }

    // MARK: - Different Items Tests

    @Test("Works with different featured items")
    func testDifferentItems() async {
        let locator = makeServiceLocator()

        let items: [FeaturedItem] = [.swiftUI, .asyncSequence, .mvvm, .coordinator]
        for item in items {
            let viewModel = DetailViewModel(item: item, serviceLocator: locator)
            #expect(viewModel.itemTitle == item.title)
            #expect(viewModel.category == item.category)
        }
    }

    // MARK: - AI Summary Tests

    @Test("showAISummary is true when toggle on and AI available")
    func testShowAISummaryTrue() async {
        let aiService = MockAIService(isAvailable: true)
        let featureToggle = MockFeatureToggleService(aiSummary: true)
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(aiService: aiService, featureToggleService: featureToggle))

        #expect(viewModel.showAISummary == true)
    }

    @Test("showAISummary is false when toggle off")
    func testShowAISummaryFalseWhenToggleOff() async {
        let aiService = MockAIService(isAvailable: true)
        let featureToggle = MockFeatureToggleService(aiSummary: false)
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(aiService: aiService, featureToggleService: featureToggle))

        #expect(viewModel.showAISummary == false)
    }

    @Test("showAISummary is false when AI unavailable")
    func testShowAISummaryFalseWhenUnavailable() async {
        let aiService = MockAIService(isAvailable: false)
        let featureToggle = MockFeatureToggleService(aiSummary: true)
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(aiService: aiService, featureToggleService: featureToggle))

        #expect(viewModel.showAISummary == false)
    }

    @Test("generateSummary sets summary text")
    func testGenerateSummarySetsText() async {
        let aiService = MockAIService(stubbedSummary: "Test summary result")
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(aiService: aiService))

        await viewModel.generateSummary()

        #expect(viewModel.summary == "Test summary result")
        #expect(viewModel.summaryError.isEmpty)
        #expect(viewModel.isSummarizing == false)
        #expect(aiService.summarizeCallCount == 1)
    }

    @Test("generateSummary handles errors")
    func testGenerateSummaryHandlesErrors() async {
        let aiService = MockAIService(shouldThrowError: true)
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(aiService: aiService))

        await viewModel.generateSummary()

        #expect(viewModel.summary.isEmpty)
        #expect(!viewModel.summaryError.isEmpty)
        #expect(viewModel.isSummarizing == false)
    }

    @Test("isSummarizing is false after generation completes")
    func testIsSummarizingStateAfterCompletion() async {
        let aiService = MockAIService(stubbedSummary: "Summary")
        let viewModel = DetailViewModel(item: testItem, serviceLocator: makeServiceLocator(aiService: aiService))

        #expect(viewModel.isSummarizing == false)

        await viewModel.generateSummary()

        #expect(viewModel.isSummarizing == false)
    }
}
}
