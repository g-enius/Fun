# Fun - iOS Demo App

[![CI](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml/badge.svg)](https://github.com/g-enius/Fun-iOS/actions/workflows/ci.yml)

A modern iOS application demonstrating clean architecture (MVVM-C), Swift Concurrency, modular design with Swift Package Manager, and best practices for scalable iOS development.

> **This is the `feature/swiftui-navigation` branch** — pure SwiftUI navigation (iOS 16+). See [`main`](https://github.com/g-enius/Fun-iOS) for the full 3-branch comparison, or [`async-sequence-migration`](https://github.com/g-enius/Fun-iOS/tree/feature/async-sequence-migration) for the Combine-free iOS 17+ version.

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
| Reactive & Concurrency | Combine, Swift Concurrency (async/await) |
| Architecture | MVVM + Coordinator (single `AppCoordinator`) |
| Navigation | `NavigationStack` + `NavigationPath` |
| Dependency Injection | Session-Scoped DI + Property Wrapper |
| Package Management | Swift Package Manager |
| Minimum iOS | iOS 16.0 |
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

### Single Coordinator

A single `AppCoordinator: ObservableObject` replaces the UIKit branch's 8-class coordinator hierarchy. It owns `NavigationPath` per tab and manages login/main flow transitions with session lifecycle. ViewModels receive navigation closures instead of coordinator protocol references.

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

## What Changed vs `main`

This branch replaces UIKit navigation with pure SwiftUI. See [PR #1](https://github.com/g-enius/Fun-iOS/pull/1) for the full diff, or [`main` README](https://github.com/g-enius/Fun-iOS) for the 3-branch comparison table.

| Metric | Value |
|--------|-------|
| Files deleted | 30 (coordinators, protocols, mocks, UIViewControllers) |
| Net reduction | **-1,152 lines** |
| Navigation | `UINavigationController` → `NavigationStack` + `NavigationPath` |
| App entry | `AppDelegate` + `SceneDelegate` → SwiftUI `@main App` |
| Coordinator | 8-class hierarchy → single `AppCoordinator: ObservableObject` |
| ViewModel → nav | `weak var coordinator: Protocol?` → closures (`onShowDetail`, etc.) |
| Deep links | `scene(_:openURLContexts:)` → `.onOpenURL { }` |

### Why NavigationStack + NavigationPath over NavigationLink

This branch uses **programmatic navigation** exclusively — `NavigationStack` with `NavigationPath` managed by the coordinator. `NavigationLink` is deliberately avoided:

- **Navigation belongs in the coordinator, not the view.** `NavigationLink` couples navigation decisions to SwiftUI views, making it hard to trigger navigation from ViewModels, deep links, or programmatic flows.
- **NavigationLink(isActive:) and NavigationLink(tag:selection:) are deprecated** since iOS 16. Apple replaced them with `navigationDestination(for:)` + `NavigationPath`, which is exactly what this branch uses.
- **NavigationPath is type-erased and composable.** The coordinator can `path.append(any Hashable)` without Views knowing the destination type. `NavigationLink` requires the destination View at the call site.
- **Testing is simpler.** Navigation is testable via closures on ViewModels (`onShowDetail`, `onShowProfile`) — no need to tap UI elements.

```swift
// How navigation works in this branch:
// 1. View calls ViewModel closure
viewModel.didTapFeaturedItem(item)

// 2. ViewModel fires navigation closure (set by coordinator)
onShowDetail?(item)

// 3. Coordinator appends to NavigationPath
coordinator.homePath.append(item)

// 4. NavigationStack picks up the change via .navigationDestination(for:)
```

### If you support iOS 17+: how this code evolves

If your deployment target is iOS 17+, you can remove Combine entirely. Here's how each pattern changes:

**ViewModels** — `ObservableObject` + `@Published` → `@Observable`:
```swift
// iOS 16 (this branch)                    // iOS 17+ (async-sequence-migration)
class HomeViewModel: ObservableObject {     @Observable class HomeViewModel {
    @Published var items = []                   var items = []
    @Published var isLoading = false             var isLoading = false
}                                           }
```

**Views** — `@ObservedObject` / `@StateObject` → `@Bindable` / `@State`:
```swift
// iOS 16 (this branch)                    // iOS 17+
@ObservedObject var viewModel: HomeVM       @Bindable var viewModel: HomeVM
@StateObject var viewModel = HomeVM()       @State var viewModel = HomeVM()
```

**Service events** — `AnyPublisher` → `AsyncStream`:
```swift
// iOS 16 (this branch)                    // iOS 17+
favoritesService.favoritesDidChange         let stream = favoritesService.favoritesChanges
    .sink { self.favoriteIds = $0 }         Task { for await ids in stream {
    .store(in: &cancellables)                   self.favoriteIds = ids
                                            }}
```

See the [`async-sequence-migration`](https://github.com/g-enius/Fun-iOS/tree/feature/async-sequence-migration) branch for the complete migration ([PR #2](https://github.com/g-enius/Fun-iOS/pull/2)).

## Testing

- **Unit Tests**: ViewModels, services, and session lifecycle
- **Session DI Tests**: Activation, teardown, transitions, state isolation
- **Snapshot Tests**: Visual regression testing for all views
- **Parameterized Tests**: Swift Testing with custom scenarios

## Getting Started

### Requirements
- Xcode 16.0+
- iOS 16.0+
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

This project demonstrates **AI-assisted iOS development** using [Claude Code](https://claude.ai/code) with project-level configuration for team-shareable guardrails, branch-aware rules, and custom workflows.

![Claude Code Demo](assets/claude-code-demo.gif)

Architecture and patterns designed by developer. Claude Code assists with feature implementation, bug fixes, testing, cross-platform parity checks, and code review — guided by project-level rules that enforce the architecture.

Commits with AI assistance include `Co-Authored-By: Claude` attribution.

### Claude Code Project Configuration

```
.claude/
├── settings.json                  # Team-shared permissions (auto-approve build/test/lint)
├── skills/
│   ├── review/SKILL.md            # /review — architecture + similar-pattern search
│   ├── fix-issue/SKILL.md         # /fix-issue — end-to-end GitHub issue workflow
│   ├── cross-platform/SKILL.md    # /cross-platform — iOS vs Android parity check
│   └── pull-request/SKILL.md      # /pull-request — draft PR with tests + accessibility
└── agents/
    └── change-reviewer.md         # Branch-aware code review agent
CLAUDE.md                          # Architecture rules, anti-patterns, build commands
ai-rules/
├── general.md                     # MVVM-C patterns, DI, sessions, testing reference
├── swift-style.md                 # Swift 6 concurrency, naming, reactive patterns
└── ci-cd.md                       # GitHub Actions CI workflow patterns
```

**Branch-aware**: Each branch has its own `CLAUDE.md` and `ai-rules/` adapted for that branch's architecture. The change-reviewer agent knows which patterns to enforce — e.g., flagging `import Combine` on the `async-sequence` branch, or `import UIKit` on the SwiftUI branches.

**Multi-branch workflow**: Shared changes commit to `main` first, then feature branches rebase — enforced via project-level rules.

**Cross-platform**: The `/cross-platform` skill compares iOS and Android implementations to catch unintentional UI/behavior divergences.

---

MIT License
