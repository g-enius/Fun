# Fun-iOS

## Multi-Branch Workflow
- 3 worktrees: `Fun-iOS` (main), `Fun-iOS-NavigationStack` (feature/navigation-stack), `Fun-iOS-NavigationStack-Async-Sequence` (feature/async-sequence)
- **Always commit shared changes to main first**, push, then rebase feature branches onto main
- Never make the same change independently on multiple branches

## Quality Standards
- Production-quality Swift 6 with strict concurrency. Think about actor isolation and Sendable before writing code.
- Clarify before coding when requirements are ambiguous. Don't guess — ask.
- Test what you build. Run the full test suite after changes.
- Follow existing patterns in the codebase. Consistency > novelty.

## Build & Test
- Workspace: `Fun.xcworkspace` (required for SPM test discovery — project alone won't work)
- Build: `xcodebuild build -workspace Fun.xcworkspace -scheme FunApp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO`
- Test: `xcodebuild test -workspace Fun.xcworkspace -scheme FunApp -skip-testing UITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO`
- Lint: `swiftlint lint --quiet`
- `swift test` does NOT work — packages are iOS-only, no macOS target

## SPM Module Names
| Package dir | Import as | Library product |
|---|---|---|
| `Core/` | `import FunCore` | `FunCore` |
| `Model/` | `import FunModel` | `FunModel` |
| `Model/` (tests) | `import FunModelTestSupport` | `FunModelTestSupport` |
| `Services/` | `import FunServices` | `FunServices` |
| `ViewModel/` | `import FunViewModel` | `FunViewModel` |
| `UI/` | `import FunUI` | `FunUI` |
| `Coordinator/` | `import FunCoordinator` | `FunCoordinator` |

## Dependency Direction
```
Coordinator → UI → ViewModel → Model → Core
                    Services → Model → Core
```
Never import upward. ViewModel must NOT import UI or Coordinator. Model must NOT import Services.

## Anti-Patterns (Red Flags)
- `import UIKit` anywhere — this branch is pure SwiftUI, zero UIKit
- Coordinator references in ViewModels (except weak optional closures) — retain cycle risk
- `print()` anywhere — use LoggerService
- `UserDefaults.standard` outside Services — use FeatureToggleService
- Adding `fatalError()` for missing services — ServiceLocator.resolve() already crashes with `fatalError` if a service isn't registered; don't add redundant guards
- Navigation logic in Views — navigation decisions belong in Coordinators only
- Protocol definitions in Services — domain protocols go in Model, reusable abstractions in Core

## Architecture (this branch: feature/navigation-stack)
- **Entry point**: SwiftUI `@main App` struct (`FunApp.swift`) — no AppDelegate or SceneDelegate
- **Navigation**: Single `AppCoordinator: ObservableObject` with per-tab `NavigationPath`
- **Views**: Pure SwiftUI views, no UIHostingController or UIViewControllers
- **Reactive**: Combine (`@Published`, `@StateObject`, `@ObservedObject`, `.sink`)
- **ViewModel → Coordinator**: Optional closures wired in tab content wrappers via `.task { viewModel.onShowDetail = { ... } }`
- **Tab bar**: SwiftUI `TabView(selection: $coordinator.selectedTab)`
- **Push nav**: `coordinator.showDetail(item, in: .home)` — named methods on AppCoordinator
- **Modals**: `.sheet(isPresented: $coordinator.isProfilePresented)`
- **DI**: ServiceLocator with `@Service` property wrapper, session-scoped (LoginSession / AuthenticatedSession)

## Rule Index
Consult these files for detailed guidance (not auto-loaded — read on demand):
- `ai-rules/general.md` — Architecture deep-dive, MVVM-C patterns, DI, sessions, testing
- `ai-rules/swift-style.md` — Swift 6 concurrency, naming, Combine patterns, SwiftLint rules
- `ai-rules/ci-cd.md` — GitHub Actions CI workflow patterns

## Code Style
- Swift 6 strict concurrency, iOS 17+
- Pure SwiftUI (NavigationStack), MVVM-C with Combine
- Single AppCoordinator: ObservableObject with @Published NavigationPath per tab
- ViewModels use closures for navigation, wired in tab content wrappers
- Navigation logic ONLY in Coordinators, never in Views
- Protocol placement: Core = reusable abstractions, Model = domain-specific
- ServiceLocator with @Service property wrapper
- Combine over NotificationCenter for reactive state

## Testing
- Swift Testing framework (`import Testing`, `@Test`, `#expect`, `@Suite`)
- Use `init()` on test structs for common setup, not `setupServices()` in every test
- Consolidate thin init tests into a single test when they test the same concern
- Centralized mocks in `Model/Sources/ModelTestSupport/Mocks/`
- Snapshot tests with swift-snapshot-testing
- Avoid polling in tests — use `Task.sleep` at suspension points, never spin-loops checking state
