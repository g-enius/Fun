# Fun-iOS Architecture Reference (feature/async-sequence)

## SPM Package Structure

6 local packages + 1 Xcode app target, unified by `Fun.xcworkspace`:

```
FunApp/FunApp.xcodeproj    → iOS app target (FunApp.swift @main, AppSessionFactory)
Coordinator/               → FunCoordinator (single AppCoordinator + views)
UI/                        → FunUI (SwiftUI views)
ViewModel/                 → FunViewModel (business logic, @Observable-compatible state)
Model/                     → FunModel + FunModelTestSupport (domain types, protocols, mocks)
Services/                  → FunServices (concrete service implementations)
Core/                      → FunCore (DI container, Session protocol, StreamBroadcaster, utilities)
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

## MVVM-C Architecture (AsyncSequence Variant)

### Single @Observable AppCoordinator
This branch uses `@Observable` (not ObservableObject) with `@ObservationIgnored` for non-observed state:

```swift
@MainActor
@Observable
public final class AppCoordinator {
    // Observed by SwiftUI
    public var currentFlow: AppFlow = .login
    public var selectedTab: TabIndex = .home
    public var homePath = NavigationPath()
    public var itemsPath = NavigationPath()
    public var settingsPath = NavigationPath()
    public var isProfilePresented = false
    public var activeToast: ToastEvent?
    public var appearanceMode: AppearanceMode = .system

    // Not observed
    @ObservationIgnored @Service(.logger) private var logger: LoggerService
    @ObservationIgnored private let sessionFactory: SessionFactory
    @ObservationIgnored private var currentSession: Session?
    @ObservationIgnored private var pendingDeepLink: DeepLink?
    @ObservationIgnored private var toastObservation: Task<Void, Never>?
}
```

### StreamBroadcaster (in FunCore)
Replaces Combine's Subject pattern. One-to-many AsyncStream broadcaster:
```swift
@MainActor
public final class StreamBroadcaster<Element: Sendable> {
    func makeStream() -> AsyncStream<Element>  // Each consumer gets independent stream
    func yield(_ value: Element)                // Broadcast to all consumers
    func finish()                               // Complete all streams
}
```

Services use `StreamBroadcaster` to emit events. Consumers iterate with `for await`:
```swift
// In service
private let broadcaster = StreamBroadcaster<ToastEvent>()
func makeStream() -> AsyncStream<ToastEvent> { broadcaster.makeStream() }

// In coordinator/viewmodel
Task { [weak self] in
    let stream = toastService.makeStream()
    for await event in stream {
        guard let self else { return }
        self.activeToast = event
    }
}
```

### Navigation Architecture
```
FunApp (@main, uses @State not @StateObject)
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
```swift
struct HomeTabContent: View {
    let coordinator: AppCoordinator
    @State private var viewModel = HomeViewModel()  // @State, not @StateObject

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

Same as other branches — `ServiceLocator.shared` with `@Service` property wrapper.
Service events use `StreamBroadcaster` instead of Combine publishers.

### Service Keys
`ServiceKey` enum in Core: `.network`, `.logger`, `.favorites`, `.toast`, `.featureToggles`, `.ai`

## Session-Scoped DI

| Session | Services Registered | When Active |
|---|---|---|
| `LoginSession` | logger, network, featureToggles, toast | Login screen |
| `AuthenticatedSession` | logger, network, favorites, toast, featureToggles, ai | Main app |

- `AppSessionFactory` creates the right session for each `AppFlow` case
- App entry (`FunApp.swift`) creates coordinator with `@State` and calls `.start()` in `.task`

## Protocol Placement

| Package | What goes here | Example |
|---|---|---|
| Core | Reusable abstractions not tied to domain | `Session`, `ServiceLocator`, `@Service`, `StreamBroadcaster` |
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

## Key Differences from Other Branches
- No UIKit, no UIViewControllers, no UIHostingController, no BaseCoordinator
- Single coordinator (not 6 separate ones)
- Navigation via NavigationPath (declarative) instead of safePush/safePop (imperative)
- App entry via SwiftUI @main, not SceneDelegate
- `@Observable` instead of `ObservableObject` — no `@Published`, SwiftUI tracks property access automatically
- `@ObservationIgnored` for services and private state that shouldn't trigger view updates
- `@State` instead of `@StateObject` for coordinator and viewmodel ownership
- `StreamBroadcaster` replaces Combine publishers — `for await` instead of `.sink`
- `Task` for observation instead of `AnyCancellable` — cancel via `task?.cancel()`
- Zero `import Combine` in the entire codebase
