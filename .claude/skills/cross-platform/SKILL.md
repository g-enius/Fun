---
name: cross-platform
description: Compare iOS vs Android implementation for feature parity
user_invocable: true
args: "<feature-name>"
---

# /cross-platform — Feature Parity Check

Compare the implementation of a feature across Fun-iOS and Fun-Android to find unintentional divergences.

## Project Paths
- **iOS**: `~/Documents/Source/Fun-iOS/`
- **Android**: `~/Documents/Source/Fun-Android/`

## Steps

1. **Identify the feature scope**
   - Search both codebases for the feature by name, related types, and UI elements
   - Read the relevant files on both platforms

2. **Compare implementation**
   - **UI elements**: Are the same buttons, labels, inputs present on both platforms?
   - **Behavior**: Do the same actions produce the same results?
   - **Data flow**: Is the same data shown in the same way?
   - **Edge cases**: Error states, empty states, loading states — are they consistent?
   - **Navigation**: Does the feature navigate the same way on both platforms?

3. **Visual comparison**
   - Build and run on simulator (iOS) and emulator (Android) if possible
   - Take screenshots and compare layout, colors, fonts, spacing

4. **Report findings**
   - **Matches**: What's consistent across platforms
   - **Platform-appropriate differences**: Different but correct per platform conventions (OK)
   - **Unintentional divergences**: Missing features, different behavior, UI mismatches (flag these)

5. **Suggest fixes**
   - For each divergence, recommend which platform should change and what the fix looks like
