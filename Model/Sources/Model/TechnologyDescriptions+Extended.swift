//
//  TechnologyDescriptions+Extended.swift
//  Model
//
//  Additional technology descriptions split out for type_body_length compliance
//

extension TechnologyDescriptions {

    static let snapshotDescription = """
        Visual regression testing with swift-snapshot-testing:

        ```swift
        @Test func homeViewSnapshot() {
            let view = HomeView(viewModel: mockViewModel)
            assertSnapshot(of: view, as: .image)
        }
        ```

        • Captures UI as images
        • Detects unintended visual changes
        • Multiple device configurations
        • Light/dark mode variants
        """

    static let accessibilityDescription = """
        Full VoiceOver and accessibility support:

        • accessibilityIdentifier for UI testing
        • accessibilityLabel for VoiceOver
        • accessibilityHint for context

        Example:
        ```swift
        .accessibilityIdentifier("featured_card_\\(item.id)")
        .accessibilityLabel("\\(item.title), \\(item.subtitle)")
        .accessibilityHint("Double tap to view details")
        ```

        All interactive elements are accessible.
        """

    static let deploymentTargetDescription = """
        This branch requires iOS 17.0 as the minimum deployment target.

        iOS 17 unlocks:
        • @Observable macro (Observation framework) — per-property tracking
        • @Bindable for two-way bindings with @Observable classes

        Three branches demonstrate progressive iOS version requirements:
        • main: iOS 15+ (UIKit navigation + Combine)
        • navigation-stack: iOS 16+ (SwiftUI NavigationStack + Combine)
        • observation: iOS 17+ (AsyncStream + @Observable, zero Combine)

        Choose the branch that matches your app's deployment target.
        """

    static let concurrencyPatternsDescription = """
        Three approaches to the same problem: fetch 3 pages of items concurrently \
        and combine results.

        1. Callbacks (DispatchGroup + concurrent barrier queue):
        ```swift
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "fetch", attributes: .concurrent)
        var allItems: [[Item]] = Array(repeating: [], count: 3)

        for page in 0..<3 {
            group.enter()
            queue.async {
                let items = fetchPage(page)
                queue.async(flags: .barrier) {
                    allItems[page] = items
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { completion(allItems.flatMap { $0 }) }
        ```
        Note: A serial queue would execute fetches one at a time. The concurrent \
        queue runs all 3 in parallel, and the barrier flag ensures thread-safe writes.

        2. AsyncStream (makeStream + continuation):
        ```swift
        let (stream, continuation) = AsyncStream.makeStream(of: (Int, [Item]).self)
        for page in 0..<3 {
            Task { continuation.yield((page, await fetchPage(page))) }
        }
        var results: [(Int, [Item])] = []
        for await result in stream {
            results.append(result)
            if results.count == 3 { break }
        }
        continuation.finish()
        let items = results.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
        ```
        Zero Combine — this branch uses AsyncStream for all reactive patterns.

        3. async/await (TaskGroup):
        ```swift
        let items = await withTaskGroup(of: (Int, [Item]).self) { group in
            for page in 0..<3 {
                group.addTask { (page, await fetchPage(page)) }
            }
            var results: [(Int, [Item])] = []
            for await result in group { results.append(result) }
            return results.sorted { $0.0 < $1.0 }.flatMap { $0.1 }
        }
        ```

        All three produce identical results. async/await is the cleanest syntax.
        """
}
