# Swift Style Guide — Fun-iOS (main branch)

## Swift 6 Strict Concurrency

### Actor Isolation
- `@MainActor` on all ViewModels, Coordinators, ServiceLocator, Session implementations, and UI-related code
- `Sendable` conformance on value types crossing isolation boundaries (enums, structs)
- `nonisolated` only when a method genuinely doesn't touch actor-isolated state

### Self-Capture in Async Closures
- **Default to `self?.`** for ViewModel async work — if self is nil, the view is gone anyway
- `guard let self` creates a strong local ref that keeps self alive across `await` suspension points
- For `AsyncSequence` loops, `guard let self` must go INSIDE the loop body, not before the `for await`
- Zero `[unowned self]` in this codebase — correct decision, never introduce it

### Sendable Types
- All enums in Model are `Sendable` (`AppFlow`, `TabIndex`, `DeepLink`, `AppearanceMode`, etc.)
- Protocols that cross isolation boundaries include `Sendable` conformance
- Use `@unchecked Sendable` only as a last resort with documented justification

## MVVM-C Patterns

### ViewModels
- `@MainActor` class conforming to `ObservableObject`
- `@Published` properties for view state
- Optional closures for navigation: `var onShowDetail: ((FeaturedItem) -> Void)?`
- Services accessed via `@Service` property wrapper
- Private `Set<AnyCancellable>` for Combine subscriptions
- No direct UIKit imports. No coordinator references (except weak closures).

### Views (SwiftUI)
- Observe ViewModel via `@ObservedObject` or `@StateObject`
- Never make navigation decisions — call ViewModel methods which invoke closures
- Use `AccessibilityID` enum for accessibility identifiers

### Coordinators (UIKit)
- Subclass `BaseCoordinator` for safe navigation (`safePush`, `safePop`, etc.)
- Create ViewModels, wire closures, wrap in ViewControllers
- Strong child coordinator references (parent → child is intentionally strong)
- `[weak self]` in all closures that reference the coordinator

## Combine Patterns (this branch)

### Publishers
- `@Published` in ViewModels for UI-bound state
- `CurrentValueSubject` / `PassthroughSubject` in services for events
- `serviceDidRegisterPublisher` on ServiceLocator to observe dynamic service registration

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
// Registration (in Session.activate())
ServiceLocator.shared.register(DefaultLoggerService(), for: .logger)

// Resolution (in ViewModel/Coordinator)
@Service(.logger) private var logger: LoggerService
```

- Registration happens in `LoginSession.activate()` and `AuthenticatedSession.activate()`
- Resolution crashes if service isn't registered — this is intentional
- Never call `ServiceLocator.shared.resolve()` directly in Views

## Naming Conventions

### Types
- ViewModels: `HomeViewModel`, `ItemsViewModel`, `DetailViewModel`
- Views: `HomeView`, `ItemsView`, `DetailView`
- ViewControllers: `HomeViewController`, `ItemsViewController`
- Coordinators: `HomeCoordinator`, `ItemsCoordinator`
- Services: protocol `FavoritesServiceProtocol`, impl `DefaultFavoritesService`
- Sessions: `LoginSession`, `AuthenticatedSession`

### Navigation Closures
- `onShowDetail`, `onShowProfile`, `onLoginSuccess`, `onLogout`, `onPop`, `onShare`, `onDismiss`, `onGoToItems`
- Always optional, always set by the Coordinator

### Service Protocols
- Suffix with `Protocol` when the name would otherwise collide: `FavoritesServiceProtocol`, `FeatureToggleServiceProtocol`, `ToastServiceProtocol`, `AIServiceProtocol`
- No suffix when unambiguous: `LoggerService`, `NetworkService`

## SwiftLint Rules

Zero-tolerance — CI fails on any violation. Key rules:

### Custom Rules
- **`no_print`**: Use `LoggerService` instead of `print()`
- **`weak_coordinator_in_viewmodel`**: Coordinator vars in ViewModels must be `weak`
- **`weak_delegate`**: Delegate properties must be `weak`
- **`no_direct_userdefaults`**: Use `FeatureToggleService`, not `UserDefaults.standard` (exempt: Services/)

### Enforced Opt-In Rules
- `force_unwrapping` — no force unwraps
- `implicitly_unwrapped_optional` — no IUOs
- `fatal_error_message` — fatal errors must have a message
- `modifier_order` — consistent modifier ordering
- `yoda_condition` — no `42 == x`

### Limits
- Line length: warning 120, error 200 (ignores URLs, function declarations, comments)
- File length: warning 500, error 1000
- Function body: warning 60, error 100
- Cyclomatic complexity: warning 15, error 25

## Error Handling

- `assertionFailure()` for programmer errors that shouldn't crash in production (e.g., missing service)
- `fatalError()` only in ServiceLocator.resolve() — a missing service IS a programming error
- Never silently swallow errors — log them via LoggerService at minimum
- Use `Result` or `throws` for recoverable errors

## Protocol Placement Rules

| If the protocol... | Put it in... |
|---|---|
| Is a reusable abstraction (DI, lifecycle) | `Core` |
| Defines domain behavior (services, factories) | `Model` |
| Is only needed by one implementation | Probably don't need a protocol |

Never define protocols in `Services`, `ViewModel`, `UI`, or `Coordinator`.
