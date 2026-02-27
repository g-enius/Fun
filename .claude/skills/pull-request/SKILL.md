---
name: pull-request
description: Create a well-structured draft pull request with tests and accessibility checks
user_invocable: true
---

# /pull-request — iOS Pull Request Workflow

Create a draft PR following the team's quality standards.

## Steps

1. **Pre-flight checks**
   - Run `swiftlint lint --quiet` — fix any violations first
   - Run tests: `xcodebuild test -workspace Fun.xcworkspace -scheme FunApp -skip-testing UITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO`
   - Build on simulator to verify UI and behavior

2. **Review changes**
   - `git diff main...HEAD` to review all changes
   - Verify package dependency direction isn't violated
   - Check for any `print()`, `UserDefaults.standard`, or other anti-patterns
   - Verify zero UIKit imports (this branch is pure SwiftUI)

3. **Accessibility checklist** (for UI changes)
   - Dynamic Type: Do text elements scale with user font size preference?
   - VoiceOver: Are interactive elements labeled with `accessibilityLabel` or `AccessibilityID`?
   - Color Contrast: Are colors distinguishable in both light and dark mode?
   - Reduce Motion: Are animations wrapped in `@Environment(\.accessibilityReduceMotion)` checks where appropriate?

4. **Create branch** (if not already on a feature branch)
   - `git checkout -b <branch-name>`

5. **Commit**
   - Simple commit message describing what changed and why
   - Stage specific files, not `git add .`

6. **Push and create draft PR**
   - `git push -u origin <branch-name>`
   - Create as **draft** PR: `gh pr create --draft --title "..." --body "..."`
   - Include: Summary (what/why), test plan, accessibility notes (if UI change)

7. **Cross-platform parity**
   - Check if the same change should be applied to `Fun-Android`
   - Note in PR description if cross-platform work is needed
