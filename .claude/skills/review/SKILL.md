---
name: review
description: Comprehensive code review with architecture checks, similar pattern search, and cross-platform parity
user_invocable: true
---

# /review — Code Review

Review all recent code changes for completeness, correctness, and consistency with Fun-iOS architecture.

## Steps

1. **Discover changes**
   - `git diff` and `git diff --cached` for unstaged/staged changes
   - `git log --oneline -5` for recent commit context
   - Read each changed file for full context

2. **Lint check**
   - Run `swiftlint lint --quiet` and flag any violations

3. **Architecture check**
   - Verify package dependency direction: `Coordinator → UI → ViewModel → Model → Core`, `Services → Model → Core`
   - No `import UIKit` in ViewModel or Model
   - No coordinator references in ViewModels (except weak closures)
   - No `print()` — use LoggerService
   - No `UserDefaults.standard` outside Services
   - Navigation logic only in Coordinators
   - Protocols in Core (reusable) or Model (domain), never in Services/ViewModel/UI/Coordinator
   - Branch-specific: Combine patterns (this branch uses Combine + UIKit coordinators)

4. **Similar pattern search**
   - Search the codebase for code that follows the same pattern as what changed
   - If the same improvement should be applied elsewhere, flag each location

5. **Correctness check**
   - Logic errors, type safety, concurrency (Swift 6 strict), memory management (`[weak self]`)
   - Verify `@MainActor` isolation, `Sendable` conformance where needed

6. **Cross-platform parity**
   - Compare with `~/Documents/Source/Fun-Android/` for the same feature
   - Flag unintentional UI/behavior divergences
   - Allow platform-specific patterns (SwiftUI vs Compose idioms are fine)

## Output Format

```
### Changes Summary
Brief description of what changed and why.

### What Looks Good
Specific things done well.

### Findings
For each issue:
- **Severity**: Critical | Important | Suggestion
- **File & Location**: path:line
- **Issue**: Clear description
- **Recommendation**: Concrete fix

### Completeness Assessment
Missing files, test gaps, documentation needs.

### Overall Verdict
Ship it | Minor fixes needed | Needs significant work
```
