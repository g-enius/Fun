# Fun - iOS Demo App

[![CI](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml)

A modern iOS application demonstrating clean architecture (MVVM-C), Swift Concurrency, modular design with Swift Package Manager, and best practices for scalable iOS development.

> **This is the `feature/async-sequence` branch** — zero Combine, pure AsyncSequence + @Observable (iOS 17+). See [`main`](https://github.com/g-enius/Fun-iOS) for the full 3-branch comparison, or [`navigation-stack`](https://github.com/g-enius/Fun-iOS/tree/feature/navigation-stack) for the iOS 16+ Combine version.

Android counterpart: [Fun-Android](https://github.com/g-enius/Fun-Android).

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
| UI Framework | SwiftUI (pure — no UIKit navigation) |
| Reactive & Concurrency | Swift Concurrency (AsyncStream, async/await) — **zero Combine** |
| State Observation | `@Observable` macro (Observation framework) |
| Architecture | MVVM + Coordinator (single `AppCoordinator`) |
| Navigation | `NavigationStack` + `NavigationPath` |
| Dependency Injection | Session-Scoped DI + Property Wrapper |
| Package Management | Swift Package Manager |
| Minimum iOS | iOS 17.0 |
| On-Device LLM | Apple Intelligence / Foundation Models (iOS 26+) |
| Testing | Swift Testing, swift-snapshot-testing |

## Module Structure

```
Fun-iOS/
├── FunApp/         # iOS app target (Xcode project)
├── Coordinator/    # Navigation coordinators
├── UI/             # SwiftUI views
├── ViewModel/      # Business logic (MVVM)
├── Model/          # Data models & protocols
├── Services/       # Concrete service implementations
└── Core/           # Utilities, DI container, L10n
```

All modules except `FunApp` are Swift packages. `FunApp` is the Xcode project that consumes them.

**Dependency Hierarchy:**

Modules only import from layers below them.

```
┌─────────────────────────────────────────┐
│               FunApp                    │
├──────────┬──────────────────────────────┤
│          │       Coordinator            │
│          ├──────────────────────────────┤
│ Services │            UI                │
│          ├──────────────────────────────┤
│          │         ViewModel            │
├──────────┴──────────────────────────────┤
│                 Model                   │
├─────────────────────────────────────────┤
│                 Core                    │
└─────────────────────────────────────────┘
```

| Module | Direct Dependencies |
|--------|-------------------|
| Core | — |
| Model | Core |
| ViewModel | Model, Core |
| Services | Model, Core |
| UI | ViewModel, Model, Core |
| Coordinator | UI, ViewModel, Model, Core |
| FunApp | All 6 |

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

### Single Coordinator

A single `AppCoordinator: @Observable` replaces the UIKit branch's 8-class coordinator hierarchy. It owns `NavigationPath` per tab and manages login/main flow transitions with session lifecycle. ViewModels receive navigation closures instead of coordinator protocol references.

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
- **Reactive Data Flow**: `AsyncStream` + `StreamBroadcaster` for service events, `@Observable` for state
- **Feature Toggles**: Runtime flags persisted via services
- **AI Summary**: On-device LLM summarisation using Apple Intelligence / Foundation Models (iOS 26+)
- **Error Handling**: Centralized `AppError` enum with toast notifications
- **Modern Search**: Debounced input, loading states
- **Pull-to-Refresh**: Native SwiftUI `.refreshable`
- **Dark Mode & Dynamic Type**: System-adaptive colors, semantic font styles, System/Light/Dark appearance picker
- **iOS 17+ APIs**: Symbol effects, sensory feedback (backwards compatible)

## What Changed vs `navigation-stack`

This branch removes all Combine in favor of AsyncSequence + @Observable. See [PR #2](https://github.com/g-enius/Fun-iOS/pull/2) for the full diff, or [`main` README](https://github.com/g-enius/Fun-iOS) for the 3-branch comparison table.

| Aspect | Before (Combine) | After (AsyncSequence) |
|--------|-------------------|------------------------|
| Service events | `AnyPublisher<T, Never>` + `Subject` | `AsyncStream<T>` + `StreamBroadcaster` |
| Subscribe | `.sink { }.store(in: &cancellables)` | `Task { for await value in stream { } }` |
| ViewModel | `ObservableObject` + `@Published` | `@Observable` macro |
| View binding | `@ObservedObject` / `@StateObject` | `@Bindable` / `@State` |
| Coordinator | `AppCoordinator: ObservableObject` | `AppCoordinator: @Observable` |
| Lifecycle cleanup | `Set<AnyCancellable>` | Task cancellation |
| Debounced search | `.debounce(for:scheduler:)` | `didSet` + `Task.sleep` with cancellation |
| `import Combine` | Throughout | **None** |

### Key patterns

**StreamBroadcaster** — multi-consumer `AsyncStream` replacement for Combine Subjects:
```swift
let broadcaster = StreamBroadcaster<Set<String>>()
let stream = broadcaster.makeStream()  // each consumer gets its own stream
broadcaster.yield(newValue)            // delivers to all active consumers
```

**Retain-safe observation** — capture stream before Task, guard inside loop:
```swift
let stream = favoritesService.favoritesChanges
observation = Task { [weak self] in
    for await newFavorites in stream {
        guard let self else { break }
        self.favoriteIds = newFavorites
    }
}
```

### Migration pitfalls

Things discovered during the Combine → AsyncSequence migration that aren't obvious:

**1. `guard let self` before `for await` creates a retain cycle.** The `guard` captures `self` strongly, and that strong reference persists for the entire duration of the `for await` suspension — the ViewModel can never deallocate.

```swift
// BAD — retains self forever during suspension
Task { [weak self] in
    guard let self else { return }
    for await value in stream { self.property = value }
}

// GOOD — guard inside the loop, break if nil
Task { [weak self] in
    for await value in stream {
        guard let self else { break }
        self.property = value
    }
}
```

**2. AsyncStream doesn't auto-emit the current value.** Unlike `@Published` (which emits immediately on subscribe), `AsyncStream` only delivers future values. Read the current value directly at init time:
```swift
// Must initialize manually — stream won't deliver the current state
favoriteIds = favoritesService.favorites     // read current
let stream = favoritesService.favoritesChanges  // observe future
```

**3. `@Observable` transforms stored properties into computed ones.** This means `@Service` (a property wrapper) can't be applied directly — it conflicts with `@Observable`'s generated accessors. Fix: mark service properties with `@ObservationIgnored`:
```swift
@ObservationIgnored @Service(.network) private var networkService: NetworkService
```

**4. `@StateObject` doesn't work with `@Observable`.** `@StateObject` requires `ObservableObject` conformance. Use `@State` instead for ownership, `@Bindable` for two-way binding (replaces `@ObservedObject`).

**5. Capture service references before suspension points.** If a shared singleton (like `ServiceLocator`) can be reset during `await`, your `@Service` property wrapper may resolve to a different (or nil) instance after resuming:
```swift
// Capture before the suspension point
let toast = toastService
try? await Task.sleep(nanoseconds: delay)
toast.showToast(message: "Error", type: .error)  // uses captured reference
```

## Testing

- **Unit Tests**: ViewModels, services, and session lifecycle
- **Session DI Tests**: Activation, teardown, transitions, state isolation
- **Snapshot Tests**: Visual regression testing for all views
- **Parameterized Tests**: Swift Testing with custom scenarios

## Getting Started

### Requirements
- Xcode 16.0+
- iOS 17.0+
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
