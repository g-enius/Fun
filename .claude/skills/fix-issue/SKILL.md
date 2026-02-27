---
name: fix-issue
description: End-to-end GitHub issue investigation, fix, test, and PR workflow
user_invocable: true
args: "<issue-number>"
---

# /fix-issue — GitHub Issue Fix Workflow

Investigate, fix, test, and prepare a PR for a GitHub issue.

## Steps

1. **Fetch issue details**
   - `gh issue view <number>` to read the full issue
   - Understand the problem, expected behavior, and any reproduction steps

2. **Investigate root cause**
   - Search the codebase for relevant files and patterns
   - Read the code thoroughly before making changes
   - Identify the root cause, not just symptoms

3. **Implement the fix**
   - Make minimal, focused changes
   - Follow existing patterns in the codebase
   - Respect package dependency direction: `Coordinator → UI → ViewModel → Model → Core`
   - No over-engineering — fix the issue, nothing more

4. **Run tests**
   - `xcodebuild test -workspace Fun.xcworkspace -scheme FunApp -skip-testing UITests -destination 'platform=iOS Simulator,name=iPhone 17 Pro' CODE_SIGNING_ALLOWED=NO`
   - Add or update tests to cover the fix
   - Run `swiftlint lint --quiet`

5. **Build and verify on simulator**
   - Build and run on the simulator to verify the fix visually
   - Take a screenshot for comparison

6. **Commit and PR**
   - Simple commit message describing the fix
   - Create a draft PR referencing the issue: `Fixes #<number>`

7. **Cross-platform check**
   - Ask if the same fix should be applied to `Fun-Android`
