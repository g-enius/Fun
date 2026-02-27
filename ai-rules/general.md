# Fun-iOS Architecture Reference

## SPM Package Structure

6 local packages + 1 Xcode app target, unified by `Fun.xcworkspace`:

```
FunApp/FunApp.xcodeproj    → iOS app target (AppDelegate, SceneDelegate, AppSessionFactory)
Coordinator/               → FunCoordinator (navigation logic)
UI/                        → FunUI (SwiftUI views + UIViewControllers)
ViewModel/                 → FunViewModel (business logic, @Published state)
Model/                     → FunModel + FunModelTestSupport (domain types, protocols, mocks)
Services/                  → FunServices (concrete service implementations)
Core/                      → FunCore (DI container, Session protocol, utilities)
```

### Dependency Graph
```
FunApp
  └─ FunCoordinator
       ├─ FunUI
       │    ├─ FunViewModel
       │    │    ├─ FunModel → FunCore
       │    │    └─ FunCore
       │    ├─ FunModel → FunCore
       │    └─ FunCore
       ├─ FunViewModel (see above)
       ├─ FunModel (see above)
       └─ FunCore

FunServices
  ├─ FunModel → FunCore
  └─ FunCore
```

Services is a sibling to the UI stack — it depends on Model and Core but NOT on ViewModel, UI, or Coordinator.

## MVVM-C Architecture

### Coordinators (UIKit, in FunCoordinator)
- `AppCoordinator` — Root coordinator. Manages login ↔ main flow transitions, deep links, session lifecycle.
- `BaseCoordinator` — Base class with `safePush()`, `safePop()`, `safePresent()`, `safeDismiss()`, `share(text:)`. Handles transition-during-animation queuing.
- `LoginCoordinator` — Login flow
- `HomeCoordinator` — Home tab (detail + profile push/modal)
- `ItemsCoordinator` — Items tab
- `SettingsCoordinator` — Settings tab

### Navigation Rules
- Navigation decisions ONLY happen in Coordinators
- ViewModels communicate navigation intent via optional closures: `onShowDetail`, `onShowProfile`, `onLoginSuccess`, `onLogout`, `onPop`, `onShare`, `onDismiss`, `onGoToItems`
- Coordinators wire these closures when creating ViewModels
- Views call ViewModel methods, which invoke closures — Views never know about Coordinators

### View Embedding Pattern (this branch)
SwiftUI views are embedded in UIKit via UIViewControllers:
```swift
// In Coordinator:
let viewModel = HomeViewModel()
viewModel.onShowDetail = { [weak self] item in self?.showDetail(for: item) }
let viewController = HomeViewController(viewModel: viewModel)
safePush(viewController)

// HomeViewController wraps HomeView(viewModel:) in UIHostingController
```

## ServiceLocator & @Service

### Registration
Services are registered in session `activate()` methods:
```swift
// LoginSession.activate()
locator.register(DefaultLoggerService(), for: .logger)
locator.register(NetworkServiceImpl(), for: .network)
locator.register(DefaultFeatureToggleService(), for: .featureToggles)

// AuthenticatedSession.activate() — adds favorites, toast, ai
```

### Resolution
```swift
@Service(.logger) private var logger: LoggerService
@Service(.favorites) private var favoritesService: FavoritesServiceProtocol
```
Resolution crashes with `fatalError` if service isn't registered. This is intentional — a missing service means a programming error.

### Service Keys
`ServiceKey` enum in Core: `.network`, `.logger`, `.favorites`, `.toast`, `.featureToggles`, `.ai`

## Session-Scoped DI

Two session types control which services are available:

| Session | Services Registered | When Active |
|---|---|---|
| `LoginSession` | logger, network, featureToggles | Login screen |
| `AuthenticatedSession` | logger, network, favorites, toast, featureToggles, ai | Main app |

- `activate()` registers services on `ServiceLocator.shared`
- `teardown()` calls `favoritesService.resetFavorites()` (AuthenticatedSession) then `ServiceLocator.shared.reset()`
- `AppSessionFactory` creates the right session for each `AppFlow` case

## Protocol Placement

| Package | What goes here | Example |
|---|---|---|
| Core | Reusable abstractions not tied to domain | `Session`, `ServiceLocator`, `@Service` |
| Model | Domain-specific protocols and types | `LoggerService`, `FavoritesServiceProtocol`, `NetworkService`, `SessionFactory`, `DeepLink`, `AppFlow`, `TabIndex` |
| Services | Concrete implementations only | `DefaultLoggerService`, `LoginSession`, `AuthenticatedSession` |

Never define a protocol in Services — protocols go in Model (domain) or Core (infrastructure).

## Deep Links

URL scheme: `funapp://`
- `funapp://tab/home`, `funapp://tab/items`, `funapp://tab/settings`
- `funapp://item/<id>`
- `funapp://profile`

Parsed by `DeepLink(url:)` in Model. Handled by `AppCoordinator.handleDeepLink(_:)`.
If received during login, stored as `pendingDeepLink` and executed after `transitionToMainFlow()`.

## Testing

- **Framework**: Swift Testing (`import Testing`, `@Test`, `#expect`, `@Suite`)
- **Test command**: `xcodebuild test -workspace Fun.xcworkspace -scheme FunApp -skip-testing UITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO`
- **Mock location**: `Model/Sources/ModelTestSupport/Mocks/` — MockLoggerService, MockNetworkService, MockFavoritesService, MockToastService, MockFeatureToggleService, MockAIService
- **Test support import**: `import FunModelTestSupport`
- **Setup pattern**: Use `init()` on test structs, not a `setupServices()` function
- **Consolidation**: Merge thin init tests into a single test when testing the same concern
- **Snapshots**: swift-snapshot-testing in UI package tests
