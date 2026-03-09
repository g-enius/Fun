# Fun-iOS Architecture Reference (feature/navigation-stack)

## SPM Package Structure

6 local packages + 1 Xcode app target, unified by `Fun.xcworkspace`:

```
FunApp/FunApp.xcodeproj    → iOS app target (FunApp.swift @main, AppSessionFactory)
Coordinator/               → FunCoordinator (single AppCoordinator + views)
UI/                        → FunUI (SwiftUI views)
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

## MVVM-C Architecture (NavigationStack Variant)

### Single AppCoordinator
Unlike the main branch (6 UIKit coordinators), this branch uses a **single `AppCoordinator: ObservableObject, ServiceLocatorProvider`** that manages all navigation state:

```swift
@MainActor
@Observable public final class AppCoordinator: ServiceLocatorProvider {
    @ObservationIgnored public let serviceLocator: ServiceLocator
    public var currentFlow: AppFlow = .login
    public var selectedTab: TabIndex = .home
    public var homePath = NavigationPath()
    public var itemsPath = NavigationPath()
    public var settingsPath = NavigationPath()
    public var isProfilePresented = false
    public var activeToast: ToastEvent?
    public var appearanceMode: AppearanceMode = .system
}
```

### Navigation Architecture
```
FunApp (@main)
  └─ AppRootView
       ├─ LoginTabContent (when currentFlow == .login)
       └─ MainTabView (when currentFlow == .main)
            ├─ homeTab: NavigationStack(path: $coordinator.homePath)
            │    └─ HomeTabContent → .navigationDestination(for: FeaturedItem.self)
            ├─ itemsTab: NavigationStack(path: $coordinator.itemsPath)
            │    └─ ItemsTabContent
            └─ settingsTab: NavigationStack(path: $coordinator.settingsPath)
                 └─ SettingsTabContent
            + .sheet(isPresented: $coordinator.isProfilePresented)
                 └─ ProfileTabContent
```

### View Wiring Pattern (this branch)
Tab content wrappers create ViewModels and wire closures:
```swift
struct HomeTabContent: View {
    let coordinator: AppCoordinator
    @State private var viewModel: HomeViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = State(wrappedValue: HomeViewModel(serviceLocator: coordinator.serviceLocator))
    }

    var body: some View {
        HomeView(viewModel: viewModel)
            .task {
                viewModel.onShowDetail = { [weak coordinator] item in
                    coordinator?.showDetail(item, in: .home)
                }
                viewModel.onShowProfile = { [weak coordinator] in
                    coordinator?.showProfile()
                }
            }
    }
}
```

## ServiceLocator & @Service

Instance-based `ServiceLocator` with `@Service` property wrapper — no `.shared` singleton. Types conform to `ServiceLocatorProvider` (+ `@ObservationIgnored` on `@Service` properties) to enable resolution from their `serviceLocator` instance.

### Service Keys
`ServiceKey` enum in Core: `.network`, `.logger`, `.favorites`, `.toast`, `.featureToggles`, `.ai`

## Session-Scoped DI

| Session | Services Registered | When Active |
|---|---|---|
| `LoginSession` | logger, network, featureToggles, toast | Login screen |
| `AuthenticatedSession` | logger, network, favorites, toast, featureToggles, ai | Main app |

- `activate()` registers services on the instance's `serviceLocator`
- `teardown()` calls `favoritesService.resetFavorites()` (AuthenticatedSession). Does NOT call `serviceLocator.reset()` — live views may still resolve services via `@Service` during SwiftUI teardown. The next session's `activate()` overwrites with fresh instances.
- `AppSessionFactory` creates the right session for each `AppFlow` case, passing the `serviceLocator` instance
- App entry (`FunApp.swift`) creates coordinator with `@State` and calls `.start()` in `.task`

## Protocol Placement

| Package | What goes here | Example |
|---|---|---|
| Core | Reusable abstractions not tied to domain | `Session`, `ServiceLocator`, `@Service` |
| Model | Domain-specific protocols and types | `LoggerService`, `FavoritesServiceProtocol`, `NetworkServiceProtocol`, `SessionFactory`, `DeepLink`, `AppFlow`, `TabIndex` |
| Services | Concrete implementations only | `DefaultLoggerService`, `LoginSession`, `AuthenticatedSession` |

Never define a protocol in Services — protocols go in Model (domain) or Core (infrastructure).

## Deep Links

URL scheme: `funapp://`
- `funapp://tab/home`, `funapp://tab/items`, `funapp://tab/settings`
- `funapp://item/<id>`
- `funapp://profile`

Parsed by `DeepLink(url:)` in Model. Handled by `AppCoordinator.handleDeepLink(_:)`.
If received during login, stored as `pendingDeepLink` and executed after `transitionToMainFlow()`.
App entry uses `.onOpenURL { url in coordinator.handleDeepLink(DeepLink(url: url)) }`.

## Testing

- **Framework**: Swift Testing (`import Testing`, `@Test`, `#expect`, `@Suite`)
- **Test command**: `xcodebuild test -workspace Fun.xcworkspace -scheme FunApp -skip-testing UITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO`
- **Mock location**: `Model/Sources/ModelTestSupport/Mocks/`
- **Test support import**: `@testable import FunModelTestSupport`
- **Snapshots**: swift-snapshot-testing in UI package tests

## Key Difference from Main Branch
- No UIKit, no UIViewControllers, no UIHostingController, no BaseCoordinator
- Single coordinator (not 6 separate ones)
- Navigation via NavigationPath (declarative) instead of safePush/safePop (imperative)
- App entry via SwiftUI @main, not SceneDelegate
