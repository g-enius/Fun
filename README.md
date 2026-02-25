# Fun - iOS Demo App

[![CI](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml)

A modern iOS application demonstrating clean architecture (MVVM-C), Swift Concurrency, modular design with Swift Package Manager, and best practices for scalable iOS development. Three branches show progressive modernization from UIKit+Combine (iOS 15) → SwiftUI Navigation (iOS 16) → AsyncSequence+@Observable (iOS 17). Android counterpart: [Fun-Android](https://github.com/g-enius/Fun-Android).

## Screenshots

| Home | Detail | Profile | Settings |
|------|--------|---------|----------|
| ![Home](assets/screenshot-home.jpg) | ![Detail](assets/screenshot-detail.jpg) | ![Profile](assets/screenshot-profile.jpg) | ![Settings](assets/screenshot-settings.jpg) |

## Demo

![App Demo](assets/demo.gif)

## Tech Stack

| Category | Technology |
|----------|------------|
| Language | Swift 6.0 |
| UI Framework | SwiftUI + UIKit |
| Reactive & Concurrency | Combine, Swift Concurrency (async/await) |
| Architecture | MVVM + Coordinator |
| Dependency Injection | Session-Scoped DI + Property Wrapper |
| Package Management | Swift Package Manager |
| Minimum iOS | iOS 15.0 |
| On-Device LLM | Apple Intelligence / Foundation Models (iOS 26+) |
| Testing | Swift Testing, swift-snapshot-testing |

## Module Structure

```
Fun-iOS/
├── FunApp/         # iOS app target (Xcode project)
├── Coordinator/    # Navigation coordinators
├── UI/             # SwiftUI views & UIKit controllers
├── ViewModel/      # Business logic (MVVM)
├── Model/          # Data models & protocols
├── Services/       # Concrete service implementations
└── Core/           # Utilities, DI container, L10n
```

All modules except `FunApp` are Swift packages. `FunApp` is the Xcode project that consumes them.

**Dependency Hierarchy:**
```
FunApp → Coordinator → UI → ViewModel → Model → Core
  └────→ Services ─────────────────────→┘
```

## Key Patterns

### MVVM + Coordinator
- **ViewModel**: Business logic, state management
- **View**: Pure UI (SwiftUI)
- **Coordinator**: Navigation flow, screen transitions

### Session-Scoped Dependency Injection

Each app flow gets its own **session** with a dedicated set of services. When the flow changes, the old session tears down and a fresh one activates — no stale state leaks between login and main.

```
LoginSession:         logger, network, featureToggles
AuthenticatedSession: logger, network, featureToggles, favorites, toast, ai
```

```swift
// Sessions activate/teardown automatically on flow transitions
protocol Session: AnyObject {
    func activate()   // register services
    func teardown()   // reset ServiceLocator
}

// ViewModels resolve lazily — no changes needed
@Service(.network) var networkService: NetworkService
```

### Protocol-Oriented Design
All services defined as protocols in `Model`, implementations in `Services`.

### Coordinator Hierarchy

```
AppCoordinator
├── LoginCoordinator
├── HomeCoordinator
│   ├── DetailCoordinator
│   └── ProfileCoordinator (modal)
├── ItemsCoordinator
│   └── DetailCoordinator
└── SettingsCoordinator
```

`AppCoordinator` manages login/main flow transitions with session lifecycle.

### Deep Linking

URL scheme `funapp://` for navigation:
- `funapp://tab/items` - Switch to Items tab
- `funapp://item/swiftui` - Open item detail
- `funapp://profile` - Open profile

Test from terminal:
```bash
xcrun simctl openurl booted "funapp://tab/items"
xcrun simctl openurl booted "funapp://item/swiftui"
xcrun simctl openurl booted "funapp://profile"
```

Deep links received during login are queued and executed after authentication.

## Features

- **Session-Scoped DI**: Clean service lifecycle per app flow — no stale state
- **Reactive Data Flow**: Combine framework with `@Published` properties
- **Feature Toggles**: Runtime flags persisted via services
- **AI Summary**: On-device LLM summarisation using Apple Intelligence / Foundation Models (iOS 26+)
- **Error Handling**: Centralized `AppError` enum with toast notifications
- **Modern Search**: Debounced input, loading states
- **Pull-to-Refresh**: Native SwiftUI `.refreshable`
- **Dark Mode & Dynamic Type**: System-adaptive colors, semantic font styles, System/Light/Dark appearance picker
- **iOS 17+ APIs**: Symbol effects, sensory feedback (backwards compatible)

## UIKit + SwiftUI Hybrid

**UIKit for navigation** (reliable Coordinator pattern), **SwiftUI for content**.

| Use Case | Framework |
|----------|-----------|
| Navigation/Presentation | UIKit (`UINavigationController` + Coordinators) |
| Content & Layout | SwiftUI (all views) |
| Forms & Settings | SwiftUI |

## Branch Comparison

Three branches demonstrate progressive modernization — same app, three architectural approaches. Choose based on your minimum iOS target.

| | `main` | [`swiftui-navigation`](https://github.com/g-enius/Fun-iOS/tree/feature/swiftui-navigation) | [`async-sequence-migration`](https://github.com/g-enius/Fun-iOS/tree/feature/async-sequence-migration) |
|---|---|---|---|
| **Minimum iOS** | **15.0** | **16.0** | **17.0** |
| Navigation | UIKit (`UINavigationController`) | SwiftUI (`NavigationStack`) | SwiftUI (`NavigationStack`) |
| Reactive state | Combine (`@Published` + `.sink`) | Combine (`@Published` + `.sink`) | AsyncSequence (`AsyncStream` + `for await`) |
| ViewModel | `ObservableObject` + `@Published` | `ObservableObject` + `@Published` | `@Observable` macro |
| View binding | `@ObservedObject` / `@StateObject` | `@ObservedObject` / `@StateObject` | `@Bindable` / `@State` |
| Service events | `AnyPublisher` + `Subject` | `AnyPublisher` + `Subject` | `AsyncStream` + `StreamBroadcaster` |
| Coordinator | Protocol hierarchy (8 classes) | Single `AppCoordinator: ObservableObject` | Single `AppCoordinator: @Observable` |
| App entry | `AppDelegate` + `SceneDelegate` | SwiftUI `@main App` | SwiftUI `@main App` |
| `import Combine` | Yes | Yes | **None** |
| PR | — | [#1](https://github.com/g-enius/Fun-iOS/pull/1) | [#2](https://github.com/g-enius/Fun-iOS/pull/2) |

All three produce **visually identical** apps — same screens, same behavior, same features.

### When to use which

| Branch | Best for |
|--------|----------|
| `main` | Apps supporting **iOS 15+**. UIKit navigation is battle-tested and gives full transition control. Combine is stable and well-understood. |
| `swiftui-navigation` | Apps on **iOS 16+**. Drops 30 files and ~1,150 lines of coordinator boilerplate. Same Combine reactive layer. |
| `async-sequence-migration` | Apps on **iOS 17+**. Zero Combine dependency. Modern Swift Concurrency throughout — `AsyncStream` for events, `@Observable` for state, Task cancellation for lifecycle. |

### Navigation: UIKit vs SwiftUI

| Aspect | `main` (UIKit) | `swiftui-navigation` / `async-sequence-migration` (SwiftUI) |
|--------|---------------|--------------------------------------------------------------|
| App entry point | `AppDelegate` + `SceneDelegate` | SwiftUI `@main App` |
| Tab bar | `UITabBarController` subclass | SwiftUI `TabView` |
| Navigation stack | `UINavigationController` | `NavigationStack` + `NavigationPath` |
| Push navigation | `pushViewController(_:animated:)` | `path.append(item)` |
| Modal presentation | `present(_:animated:)` | `.sheet(isPresented:)` |
| Coordinator → ViewModel | `weak var coordinator: HomeCoordinator?` | Closures: `var onShowDetail: ((FeaturedItem) -> Void)?` |
| Deep links | `scene(_:openURLContexts:)` | `.onOpenURL { }` |
| Transition control | Full (`UINavigationControllerDelegate`) | Limited (no custom transition API) |

### Reactive State: Combine vs AsyncSequence

| Aspect | `main` / `swiftui-navigation` (Combine) | `async-sequence-migration` (AsyncSequence) |
|--------|----------------------------------------|---------------------------------------------|
| Service publisher | `AnyPublisher<Set<String>, Never>` | `AsyncStream<Set<String>>` |
| Multi-consumer | `CurrentValueSubject` / `PassthroughSubject` | `StreamBroadcaster` (custom, in Core) |
| Subscribe | `.sink { }.store(in: &cancellables)` | `Task { for await value in stream { } }` |
| Lifecycle cleanup | `Set<AnyCancellable>` + `cancellables = []` | Task cancellation (`task.cancel()`) |
| Debounced search | `.debounce(for:scheduler:)` operator | `didSet` + `Task.sleep` with cancellation |
| Initial value | `@Published` emits on subscribe | Read property directly, stream emits future changes |
| ViewModel observation | `ObservableObject` (per-object invalidation) | `@Observable` (per-property tracking) |

### Migration stats (main → swiftui-navigation)

| Metric | Value |
|--------|-------|
| Files added | 3 |
| Files deleted | 30 (coordinators, VCs, protocols, mocks) |
| Net reduction | **-1,152 lines** |

### Migration stats (swiftui-navigation → async-sequence-migration)

| Metric | Value |
|--------|-------|
| Files changed | 49 (48 modified + 1 new) |
| Lines added | 552 |
| Lines removed | 473 |
| `import Combine` remaining | 0 |

## Testing

- **Unit Tests**: ViewModels, services, and session lifecycle
- **Session DI Tests**: Activation, teardown, transitions, state isolation
- **Snapshot Tests**: Visual regression testing for all views
- **Parameterized Tests**: Swift Testing with custom scenarios

## Getting Started

### Requirements
- Xcode 16.0+
- iOS 15.0+
- Swift 6.0

### Installation
```bash
git clone https://github.com/g-enius/Fun-iOS.git
cd Fun-iOS
open Fun.xcworkspace
```

### Running
1. Open `Fun.xcworkspace`
2. Select `FunApp` scheme
3. Choose simulator (iPhone 17 Pro recommended)
4. `Cmd + R` to build and run

### Tests
```bash
xcodebuild test -workspace Fun.xcworkspace -scheme FunApp \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Code Quality

- SwiftLint with strict rules (no force unwraps)
- GitHub Actions CI (lint, build, test)
- OSLog structured logging
- SwiftGen for type-safe localization

## AI-Assisted Development

This project demonstrates **AI-assisted iOS development** using Claude Code with MCP integration.

![Claude Code Demo](assets/claude-code-demo.gif)

Architecture and patterns designed by developer. Claude assisted with:
- Feature implementation
- Bug fixes
- Test coverage
- Documentation

Commits with AI assistance include `Co-Authored-By: Claude` attribution.

---

MIT License
