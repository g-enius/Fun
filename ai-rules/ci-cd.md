# CI/CD Patterns — Fun-iOS

## GitHub Actions Workflow

Located at `.github/workflows/ci.yml`. Triggers on push to `main` and PRs targeting `main`.

### Jobs

**1. SwiftLint**
```yaml
- runs-on: macos-latest
- brew install swiftlint
- swiftlint lint --reporter github-actions-logging
```

**2. Build & Test**
```yaml
- runs-on: macos-latest
- sudo xcode-select -s /Applications/Xcode.app
- xcodebuild build -workspace Fun.xcworkspace -scheme FunApp \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -configuration Debug CODE_SIGNING_ALLOWED=NO
- xcodebuild test -workspace Fun.xcworkspace -scheme FunApp \
    -skip-testing UITests \
    -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
    -configuration Debug CODE_SIGNING_ALLOWED=NO
```

### Key Requirements
- **Workspace, not project**: `Fun.xcworkspace` is required for SPM test target discovery. Using `FunApp.xcodeproj` causes "Scheme FunApp is not currently configured for the test action."
- **`CODE_SIGNING_ALLOWED=NO`**: CI runners don't have signing certificates
- **`-skip-testing UITests`**: Snapshot tests need specific simulator state; skip in CI
- **Configuration**: Always `Debug` for CI builds and tests

### Concurrency
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```
Duplicate runs for the same branch are automatically cancelled.

### Modifying CI
- Keep the two-job structure (lint is fast, build is slow — run in parallel)
- Always use `-workspace Fun.xcworkspace`, never `-project`
- Test destination should match a simulator available on `macos-latest`
- SwiftLint reporter `github-actions-logging` adds inline annotations to PR diffs
