# Swift Style Guide — Fun-iOS (feature/async-sequence)

## Swift 6 Strict Concurrency

### Actor Isolation
- `@MainActor` on AppCoordinator, all ViewModels, ServiceLocator, Session implementations, StreamBroadcaster
- `Sendable` conformance on value types crossing isolation boundaries
- `nonisolated` only when a method genuinely doesn't touch actor-isolated state

### Self-Capture in Async Closures
- **Default to `self?.`** for ViewModel async work — if self is nil, the view is gone anyway
- `guard let self` creates a strong local ref that keeps self alive across `await` suspension points
- For `for await` loops, `guard let self` must go INSIDE the loop body, not before the `for await`
- Zero `[unowned self]` in this codebase — never introduce it
- **`[weak coordinator]`** in tab content wrappers when wiring closures
- **`[weak self]`** in Task closures that observe streams

### Sendable Types
- All enums in Model are `Sendable` (`AppFlow`, `TabIndex`, `DeepLink`, `AppearanceMode`, etc.)
- Protocols that cross isolation boundaries include `Sendable` conformance
- `StreamBroadcaster<Element: Sendable>` — element type must be Sendable

## @Observable Patterns (this branch)

### @Observable vs ObservableObject
This branch uses Swift Observation framework, NOT Combine's ObservableObject:
- **Use `@Observable`** on coordinator and viewmodel classes (not `ObservableObject`)
- **No `@Published`** — just regular `var` properties, SwiftUI tracks access automatically
- **Use `@ObservationIgnored`** for services, private state, and anything that shouldn't trigger view updates
- **Use `@State`** (not `@StateObject`) to own @Observable objects in views
- **No `@ObservedObject`** — just pass @Observable objects directly

### ViewModels
- `@MainActor @Observable` class
- Regular `var` properties for view state (SwiftUI auto-tracks)
- `@ObservationIgnored` for services (`@Service` properties) and non-UI state
- Optional closures for navigation: `var onShowDetail: ((FeaturedItem) -> Void)?`
- `Task` for stream observation, stored as `@ObservationIgnored private var observationTask: Task<Void, Never>?`
- No UIKit imports. No coordinator references.

### Views — Passing @Observable Objects
- **`let` / `var`** — when you only **read** properties (e.g. `coordinator.currentFlow`)
- **`@Bindable`** — when you need **`$` bindings** (e.g. `$coordinator.selectedTab`, `$coordinator.isProfilePresented`)
- **`@State`** — when the view **owns** the object (e.g. tab content wrappers owning their ViewModel)
- Rule of thumb: if you see a `$` in the body, you need `@Bindable`. Otherwise plain property.
- Never make navigation decisions — call ViewModel methods which invoke closures
- No `import UIKit` anywhere in this branch

### AppCoordinator
- `@MainActor @Observable` with per-tab NavigationPath
- `@ObservationIgnored` for sessionFactory, currentSession, pendingDeepLink, observation Tasks
- Created with `@State` in the app entry point
- Tab content wrappers wire ViewModel closures using `[weak coordinator]`

## AsyncSequence Patterns (this branch — zero Combine)

### StreamBroadcaster
Central pattern replacing Combine publishers. Located in `Core/Sources/Core/StreamBroadcaster.swift`:
```swift
// Service exposes a stream factory
func makeStream() -> AsyncStream<ToastEvent> {
    broadcaster.makeStream()
}

// Consumer iterates
Task { [weak self] in
    for await event in service.makeStream() {
        guard let self else { return }
        self.handleEvent(event)
    }
}
```

### Stream Observation Lifecycle
- Start observation in `start()` or initialization methods
- Store the `Task` for cancellation: `observationTask = Task { ... }`
- Cancel in cleanup: `observationTask?.cancel()`
- Always use `[weak self]` in Task closures
- Always `guard let self` INSIDE `for await` loops

### ServiceLocator Registration Events
`serviceRegistrations` property returns `AsyncStream<ServiceKey>` (replaces Combine's `serviceDidRegisterPublisher`):
```swift
Task { [weak self] in
    for await key in ServiceLocator.shared.serviceRegistrations {
        if key == .featureToggles {
            self?.observeFeatureToggles()
        }
    }
}
```

## Naming Conventions

### Types
- AppCoordinator (single, @Observable)
- Tab content wrappers: `HomeTabContent`, `ItemsTabContent`, `SettingsTabContent`, `ProfileTabContent`, `LoginTabContent`
- ViewModels: `HomeViewModel`, `ItemsViewModel`, `DetailViewModel` (@Observable)
- Views: `HomeView`, `ItemsView`, `DetailView` (pure SwiftUI)
- Services: protocol `FavoritesServiceProtocol`, impl `DefaultFavoritesService`

### Navigation Closures
- `onShowDetail`, `onShowProfile`, `onLoginSuccess`, `onLogout`, `onDismiss`, `onGoToItems`
- Always optional, wired in tab content wrapper `.task` blocks

### Task Properties
- `private var toastObservation: Task<Void, Never>?`
- `private var darkModeObservation: Task<Void, Never>?`
- `private var registrationObservation: Task<Void, Never>?`
- `private var loadTask: Task<Void, Never>?`

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

## Things That Don't Belong in This Branch
- `import Combine` — use AsyncSequence/StreamBroadcaster instead
- `@Published` — use regular `var` with `@Observable`
- `ObservableObject` — use `@Observable`
- `@StateObject` — use `@State`
- `@ObservedObject` — pass @Observable objects directly
- `AnyCancellable` / `Set<AnyCancellable>` — use Task cancellation
- `CurrentValueSubject` / `PassthroughSubject` — use StreamBroadcaster
