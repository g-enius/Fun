# Swift Style Guide — Fun-iOS (feature/navigation-stack)

## Swift 6 Strict Concurrency

### Actor Isolation
- `@MainActor` on AppCoordinator, all ViewModels, ServiceLocator, Session implementations
- `Sendable` conformance on value types crossing isolation boundaries
- `nonisolated` only when a method genuinely doesn't touch actor-isolated state

### Self-Capture in Async Closures
- **Default to `self?.`** for ViewModel async work — if self is nil, the view is gone anyway
- `guard let self` creates a strong local ref that keeps self alive across `await` suspension points
- For `AsyncSequence` loops, `guard let self` must go INSIDE the loop body
- Zero `[unowned self]` in this codebase — never introduce it
- **`[weak coordinator]`** in tab content wrappers when wiring closures

### Sendable Types
- All enums in Model are `Sendable` (`AppFlow`, `TabIndex`, `DeepLink`, `AppearanceMode`, etc.)
- Protocols that cross isolation boundaries include `Sendable` conformance

## MVVM-C Patterns

### ViewModels
- `@MainActor` class conforming to `ObservableObject`
- `@Published` properties for view state
- Optional closures for navigation: `var onShowDetail: ((FeaturedItem) -> Void)?`
- Services accessed via `@Service` property wrapper
- Private `Set<AnyCancellable>` for Combine subscriptions
- No UIKit imports. No coordinator references.

### Views (Pure SwiftUI)
- Observe ViewModel via `@ObservedObject` or `@StateObject`
- Never make navigation decisions — call ViewModel methods which invoke closures
- No `import UIKit` anywhere in this branch

### AppCoordinator
- Single `ObservableObject` managing all navigation state
- `@Published` NavigationPath per tab + selectedTab + modal flags
- Created with `@StateObject` in the app entry point
- Tab content wrappers wire ViewModel closures using `[weak coordinator]`

## Combine Patterns (this branch)

### Publishers
- `@Published` in AppCoordinator for navigation state
- `@Published` in ViewModels for UI-bound state
- `CurrentValueSubject` / `PassthroughSubject` in services for events
- Instance-based `ServiceLocator` with `ServiceLocatorProvider` protocol

### Schedulers
- `RunLoop.main` for `debounce`/`throttle` — cooperates with `Task.sleep` in async tests
- `DispatchQueue.main` for `receive(on:)` — not affected by scroll tracking mode
- If subscriber is already `@MainActor`, `receive(on:)` is redundant — skip it

### Subscriptions
- Store in `private var cancellables = Set<AnyCancellable>()`
- Use `[weak self]` in `.sink` closures
- Cancel explicitly when needed (e.g., `darkModeCancellable?.cancel()`)

## ServiceLocator & @Service

```swift
// Instance-based DI — no .shared singleton
class MyViewModel: ObservableObject, ServiceLocatorProvider {
    let serviceLocator: ServiceLocator
    @Service(.logger) private var logger: LoggerService

    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
}
```

- `@Service` uses `static subscript(_enclosingInstance:)` to resolve from the enclosing instance's `serviceLocator`
- Registration happens in `LoginSession.activate()` and `AuthenticatedSession.activate()` on the instance
- Resolution crashes if service isn't registered — this is intentional
- Never call `serviceLocator.resolve()` directly in Views
- One `ServiceLocator()` is created in `FunApp.swift` and threaded through the entire object graph

## Naming Conventions

### Types
- AppCoordinator (single, not per-tab)
- Tab content wrappers: `HomeTabContent`, `ItemsTabContent`, `SettingsTabContent`, `ProfileTabContent`, `LoginTabContent`
- ViewModels: `HomeViewModel`, `ItemsViewModel`, `DetailViewModel`
- Views: `HomeView`, `ItemsView`, `DetailView`
- Services: protocol `FavoritesServiceProtocol`, impl `DefaultFavoritesService`

### Navigation Closures
- `onShowDetail`, `onShowProfile`, `onLoginSuccess`, `onLogout`, `onPop`, `onShare`, `onDismiss`, `onGoToItems`
- Always optional, wired in tab content wrapper `.task` blocks

### Service Protocols
- Suffix with `Protocol` when the name would otherwise collide: `FavoritesServiceProtocol`, `FeatureToggleServiceProtocol`, `ToastServiceProtocol`, `AIServiceProtocol`, `NetworkServiceProtocol`
- No suffix when unambiguous: `LoggerService`

## SwiftLint Rules

Zero-tolerance — CI fails on any violation.

### Custom Rules
- **`no_print`**: Use `LoggerService` instead of `print()`
- **`weak_coordinator_in_viewmodel`**: Coordinator vars in ViewModels must be `weak`
- **`weak_delegate`**: Delegate properties must be `weak`
- **`no_direct_userdefaults`**: Use `FeatureToggleService`, not `UserDefaults.standard` (exempt: Services/)

### Key Limits
- Line length: warning 120, error 200
- File length: warning 500, error 1000
- Function body: warning 60, error 100
- Cyclomatic complexity: warning 15, error 25

## Error Handling

- `assertionFailure()` for programmer errors that shouldn't crash in production
- `fatalError()` only in ServiceLocator.resolve()
- Never silently swallow errors — log via LoggerService

## Protocol Placement Rules

| If the protocol... | Put it in... |
|---|---|
| Is a reusable abstraction (DI, lifecycle) | `Core` |
| Defines domain behavior (services, factories) | `Model` |
| Is only needed by one implementation | Probably don't need a protocol |

Never define protocols in `Services`, `ViewModel`, `UI`, or `Coordinator`.
