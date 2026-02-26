# Fun-iOS

## Build & Test
- 6 SPM packages: Coordinator > UI > ViewModel > Model > Core, Services > Model > Core
- Xcode project: `FunApp/FunApp.xcodeproj`
- Run all tests: `xcodebuild test -scheme FunApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- Run package tests: `cd <Package> && xcodebuild test -scheme <Package> -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- `swift test` does NOT work — packages are iOS-only, no macOS target

## Code Style
- Swift 6 strict concurrency, iOS 17+
- SwiftUI + UIKit hybrid, MVVM-C with Combine
- ViewModels use closures for navigation (no coordinator protocols)
- Navigation logic ONLY in Coordinators, never in Views
- Protocol placement: Core = reusable abstractions, Model = domain-specific
- ServiceLocator with @Service property wrapper (assertionFailure, not fatalError)
- Combine over NotificationCenter for reactive state

## Testing
- Swift Testing framework (`import Testing`, `@Test`, `#expect`, `@Suite`)
- Use `init()` on test structs for common setup, not `setupServices()` in every test
- Consolidate thin init tests into a single test when they test the same concern
- Centralized mocks in `Model/Sources/Model/Mocks/`
- Snapshot tests with swift-snapshot-testing
