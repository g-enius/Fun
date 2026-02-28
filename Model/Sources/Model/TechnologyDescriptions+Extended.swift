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
        • Full NavigationStack + NavigationPath API maturity
        • Symbol effects and sensory feedback

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
        let queue = DispatchQueue(label: "concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        var items: [Item] = []

        for _ in 0..<3 {
            group.enter()
            dataSource.fetchItems { result in
                queue.asyncAndWait(flags: .barrier) {
                    items.append(contentsOf: result)
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { completion(items) }
        ```
        The concurrent queue runs all 3 fetches in parallel. asyncAndWait with \
        barrier ensures thread-safe array mutations.

        2. AsyncStream (makeStream + continuation):
        ```swift
        let (stream, continuation) = AsyncStream.makeStream(of: [Item].self)
        for _ in 0..<3 {
            Task {
                let items = await dataSource.fetchItems()
                continuation.yield(items)
            }
        }
        var items: [Item] = []
        for await result in stream {
            items.append(contentsOf: result)
            if items.count >= expectedTotal { break }
        }
        continuation.finish()
        ```
        Zero Combine — this branch uses AsyncStream for all reactive patterns.

        3. async/await (TaskGroup):
        ```swift
        var items: [Item] = []
        await withTaskGroup { group in
            for _ in 0..<3 {
                group.addTask {
                    await self.dataSource.fetchItems()
                }
            }
            for await result in group {
                items.append(contentsOf: result)
            }
        }
        return items
        ```

        All three produce identical results. async/await is the cleanest syntax.
        """
}
