# Fun - iOS Demo App

[![CI](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml)

A modern iOS application demonstrating clean architecture (MVVM-C), Swift Concurrency, modular design with Swift Package Manager, and best practices for scalable iOS development.

Three branches show progressive modernization:
- UIKit + SwiftUI + Combine (iOS 15+) — [`main`](https://github.com/g-enius/Fun-iOS/tree/main)
- Pure SwiftUI + Combine (iOS 16+) — [`navigation-stack`](https://github.com/g-enius/Fun-iOS/tree/feature/navigation-stack)
- Pure SwiftUI + AsyncSequence (iOS 17+) — [`async-sequence`](https://github.com/g-enius/Fun-iOS/tree/feature/async-sequence)

Android counterpart: [Fun-Android](https://github.com/g-enius/Fun-Android).

## Screenshots

| Home | Detail | Profile | Settings |
|------|--------|---------|----------|
| ![Home](assets/screenshot-home.jpg) | ![Detail](assets/screenshot-detail.jpg) | ![Profile](assets/screenshot-profile.jpg) | ![Settings](assets/screenshot-settings.jpg) |

## Demo

![App Demo](assets/demo.gif)

## Tech Stack & Branch Comparison

Three branches demonstrate progressive modernization — same app, three architectural approaches. Choose based on your minimum iOS target. All three produce **visually identical** apps.

| | `main` | [`navigation-stack`](https://github.com/g-enius/Fun-iOS/tree/feature/navigation-stack) | [`async-sequence`](https://github.com/g-enius/Fun-iOS/tree/feature/async-sequence) |
|---|---|---|---|
| **Best for** | **iOS 15+** | [![iOS 16+](https://img.shields.io/badge/iOS_16+-blue)](#) | [![iOS 17+](https://img.shields.io/badge/iOS_17+-blue)](#) |
| **UI framework** | **UIKit + SwiftUI** | **SwiftUI** [![🚫 UIKit](https://img.shields.io/badge/🚫_UIKit-blue)](#) | ← same |
| **Reactive** | **Combine** | ← same | **AsyncSequence** [![🚫 Combine](https://img.shields.io/badge/🚫_Combine-blue)](#) |
| **ViewModel** | `ObservableObject` + `@Published` | ← same | **@Observable** macro |
| **View binding** | `@ObservedObject` | ← same | **@Bindable** / **@State** |
| **Service events** | `AnyPublisher` + `Subject` | ← same | **AsyncStream** + **StreamBroadcaster** |
| Architecture | MVVM + Coordinator | ← same | ← same |
| Coordinator → ViewModel | Closures | ← same | ← same |
| Language | Swift 6.0 | ← same | ← same |
| DI | Session-Scoped + @Service | ← same | ← same |
| LLM | Foundation Models (iOS 26+) | ← same | ← same |
| Testing | Swift Testing, swift-snapshot-testing | ← same | ← same |
| PR | — | [#3](https://github.com/g-enius/Fun-iOS/pull/3) | [#4](https://github.com/g-enius/Fun-iOS/pull/4) |

### UIKit + SwiftUI vs Pure SwiftUI

| Aspect | `main` (UIKit + SwiftUI) | `navigation-stack` / `async-sequence` (Pure SwiftUI) |
|--------|--------------------------|------------------------------------------------------|
| App entry point | `AppDelegate` + `SceneDelegate` | SwiftUI `@main App` |
| Tab bar | `UITabBarController` subclass | SwiftUI `TabView` |
| Navigation stack | `UINavigationController` | `NavigationStack` + `NavigationPath` |
| Push navigation | `pushViewController(_:animated:)` | `path.append(item)` |
| Modal presentation | `present(_:animated:)` | `.sheet(isPresented:)` |
| Views | SwiftUI hosted in `UIHostingController` | Native SwiftUI views |
| View controllers | UIKit VCs wrap SwiftUI views | None |
| Coordinators | `HomeCoordinator`, `ItemsCoordinator`, `SettingsCoordinator` | Single `AppCoordinator` (ObservableObject) |
| Deep links | `scene(_:openURLContexts:)` | `.onOpenURL { }` |
| Transition control | Full (`UINavigationControllerDelegate`) | Limited (no custom transition API) |
| `import UIKit` | Coordinators + VCs | None |

### Reactive State: Combine vs AsyncSequence

| Aspect | `main` / `navigation-stack` (Combine) | `async-sequence` (AsyncSequence) |
|--------|----------------------------------------|---------------------------------------------|
| Service publisher | `AnyPublisher<Set<String>, Never>` | `AsyncStream<Set<String>>` |
| Multi-consumer | `CurrentValueSubject` / `PassthroughSubject` | `StreamBroadcaster` (custom, in Core) |
| Subscribe | `.sink { }.store(in: &cancellables)` | `Task { for await value in stream { } }` |
| Lifecycle cleanup | `Set<AnyCancellable>` + `cancellables = []` | Task cancellation (`task.cancel()`) |
| Debounced search | `.debounce(for:scheduler:)` operator | `didSet` + `Task.sleep` with cancellation |
| Initial value | `@Published` emits on subscribe | Read property directly, stream emits future changes |
| ViewModel observation | `ObservableObject` (per-object invalidation) | `@Observable` (per-property tracking) |

### Migration stats (main → navigation-stack)

| Metric | Value |
|--------|-------|
| Files added | 3 |
| Files deleted | 30 (coordinators, VCs, protocols, mocks) |
| Net reduction | **~1,100 lines** |

### Migration stats (navigation-stack → async-sequence)

| Metric | Value |
|--------|-------|
| Files changed | 49 (48 modified + 1 new) |
| Lines added | 552 |
| Lines removed | 473 |
| `import Combine` remaining | 0 |

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
- **Model**: Data models, protocols, domain logic
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
├── HomeCoordinator (detail + profile screens)
├── ItemsCoordinator (detail screens)
└── SettingsCoordinator
```

3 tab coordinators handle all screens in their navigation stack directly. ViewModels communicate via closures (`onShowDetail`, `onShowProfile`, `onPop`, `onShare`, `onDismiss`, `onLogin`) — no coordinator protocols.

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
