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

    private func makeSession(
        initialFavorites: Set<String> = [],
        aiService: MockAIService = MockAIService(),
        featureToggleService: MockFeatureToggleService = MockFeatureToggleService()
    ) -> MockSession {
        let locator = ServiceLocator()
        locator.register(MockLoggerService(), for: .logger)
        locator.register(MockNetworkService(), for: .network)
        locator.register(MockFavoritesService(initialFavorites: initialFavorites), for: .favorites)
        locator.register(featureToggleService, for: .featureToggles)
        locator.register(MockToastService(), for: .toast)
        locator.register(aiService, for: .ai)
        return MockSession(serviceLocator: locator)
    }

    private var testItem: FeaturedItem {
        FeaturedItem.asyncAwait
    }

    // MARK: - Initialization Tests

    @Test("Initial state matches item data")
    func testInitialStateMatchesItem() async {
        let item = testItem
        let viewModel = DetailViewModel(item: item, session: makeSession())

        #expect(viewModel.itemTitle == item.title)
        #expect(viewModel.category == item.category)
        #expect(viewModel.itemDescription == TechnologyDescriptions.description(for: item.id))
    }

    @Test("isFavorited is true when item is in favorites")
    func testIsFavoritedTrue() async {
        let item = testItem
        let viewModel = DetailViewModel(item: item, session: makeSession(initialFavorites: [item.id]))

        #expect(viewModel.isFavorited == true)
    }

    @Test("isFavorited is false when item is not in favorites")
    func testIsFavoritedFalse() async {
        let viewModel = DetailViewModel(item: testItem, session: makeSession(initialFavorites: []))

        #expect(viewModel.isFavorited == false)
    }

    // MARK: - Toggle Favorite Tests

    @Test("didTapToggleFavorite adds item to favorites")
    func testToggleFavoriteAdds() async {
        let viewModel = DetailViewModel(item: testItem, session: makeSession(initialFavorites: []))

        #expect(viewModel.isFavorited == false)

        viewModel.didTapToggleFavorite()

        // Wait for publisher to propagate
        await Task.yield()

        #expect(viewModel.isFavorited == true)
    }

    @Test("didTapToggleFavorite removes item from favorites")
    func testToggleFavoriteRemoves() async {
        let item = testItem
        let viewModel = DetailViewModel(item: item, session: makeSession(initialFavorites: [item.id]))

        #expect(viewModel.isFavorited == true)

        viewModel.didTapToggleFavorite()

        // Wait for publisher to propagate
        await Task.yield()

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
        let viewModel = DetailViewModel(item: item, session: MockSession(serviceLocator: locator))

        #expect(viewModel.isFavorited == false)

        // Change favorites externally
        mockFavorites.addFavorite(item.id)

        // Wait for publisher
        await Task.yield()

        #expect(viewModel.isFavorited == true)
    }

    // MARK: - Share Tests

    @Test("didTapShare calls onShare with item title")
    func testDidTapShareCallsOnShare() async {
        let viewModel = DetailViewModel(item: testItem, session: makeSession())

        var shareCalled = false
        var shareText: String?
        viewModel.onShare = { text in shareCalled = true; shareText = text }

        viewModel.didTapShare()

        #expect(shareCalled == true)
        #expect(shareText?.contains(testItem.title) == true)
    }

    // MARK: - Back Navigation Tests

    @Test("handleBackNavigation calls onPop")
    func testHandleBackNavigationCallsOnPop() async {
        let viewModel = DetailViewModel(item: testItem, session: makeSession())

        var popCalled = false
        viewModel.onPop = { popCalled = true }

        viewModel.handleBackNavigation()

        #expect(popCalled == true)
    }

    @Test("handleBackNavigation with nil closure does not crash")
    func testHandleBackNavigationWithNilClosure() async {
        let viewModel = DetailViewModel(item: testItem, session: makeSession())

        viewModel.handleBackNavigation() // Should not crash
    }

    // MARK: - Different Items Tests

    @Test("Works with different featured items")
    func testDifferentItems() async {
        let session = makeSession()

        let items: [FeaturedItem] = [.swiftUI, .combine, .mvvm, .coordinator]
        for item in items {
            let viewModel = DetailViewModel(item: item, session: session)
            #expect(viewModel.itemTitle == item.title)
            #expect(viewModel.category == item.category)
        }
    }

    // MARK: - AI Summary Tests

    @Test("showAISummary is true when toggle on and AI available")
    func testShowAISummaryTrue() async {
        let aiService = MockAIService(isAvailable: true)
        let featureToggle = MockFeatureToggleService(aiSummary: true)
        let viewModel = DetailViewModel(item: testItem, session: makeSession(aiService: aiService, featureToggleService: featureToggle))

        #expect(viewModel.showAISummary == true)
    }

    @Test("showAISummary is false when toggle off")
    func testShowAISummaryFalseWhenToggleOff() async {
        let aiService = MockAIService(isAvailable: true)
        let featureToggle = MockFeatureToggleService(aiSummary: false)
        let viewModel = DetailViewModel(item: testItem, session: makeSession(aiService: aiService, featureToggleService: featureToggle))

        #expect(viewModel.showAISummary == false)
    }

    @Test("showAISummary is false when AI unavailable")
    func testShowAISummaryFalseWhenUnavailable() async {
        let aiService = MockAIService(isAvailable: false)
        let featureToggle = MockFeatureToggleService(aiSummary: true)
        let viewModel = DetailViewModel(item: testItem, session: makeSession(aiService: aiService, featureToggleService: featureToggle))

        #expect(viewModel.showAISummary == false)
    }

    @Test("generateSummary sets summary text")
    func testGenerateSummarySetsText() async {
        let aiService = MockAIService(stubbedSummary: "Test summary result")
        let viewModel = DetailViewModel(item: testItem, session: makeSession(aiService: aiService))

        await viewModel.generateSummary()

        #expect(viewModel.summary == "Test summary result")
        #expect(viewModel.summaryError.isEmpty)
        #expect(viewModel.isSummarizing == false)
        #expect(aiService.summarizeCallCount == 1)
    }

    @Test("generateSummary handles errors")
    func testGenerateSummaryHandlesErrors() async {
        let aiService = MockAIService(shouldThrowError: true)
        let viewModel = DetailViewModel(item: testItem, session: makeSession(aiService: aiService))

        await viewModel.generateSummary()

        #expect(viewModel.summary.isEmpty)
        #expect(!viewModel.summaryError.isEmpty)
        #expect(viewModel.isSummarizing == false)
    }

    @Test("isSummarizing is false after generation completes")
    func testIsSummarizingStateAfterCompletion() async {
        let aiService = MockAIService(stubbedSummary: "Summary")
        let viewModel = DetailViewModel(item: testItem, session: makeSession(aiService: aiService))

        #expect(viewModel.isSummarizing == false)

        await viewModel.generateSummary()

        #expect(viewModel.isSummarizing == false)
    }
}
}
