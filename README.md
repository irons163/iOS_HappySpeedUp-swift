# HappySpeedUp (Swift port)

A Swift / SpriteKit re-implementation of the original Objective-C game
[`iOS_HappySpeedUp`](../iOS_HappySpeedUp). The hamster bounces between two
scrolling walls (tap to flip horizontal direction), grabs speed-up / speed-down
/ fly tools at score milestones, and the run ends on a wall collision. Game
Center leaderboards, a house-ad banner and background music are all ported.

## Requirements

- Xcode 15+
- iOS 14.0+ deployment target

## Getting the image assets

The binary image assets (`*.png` / `*.jpg`) are **not** duplicated in this repo.
Copy them from the original project once with the bundled script:

```bash
./copy_resources.sh                 # assumes ../iOS_HappySpeedUp is a sibling
# or
./copy_resources.sh /path/to/iOS_HappySpeedUp
```

This populates `HappySpeedUp/Images/`. After that, open
`HappySpeedUp.xcodeproj` and build/run the **HappySpeedUp** scheme.

> The unit tests do **not** depend on these assets and can run without them.

## Running the tests

```bash
xcodebuild test \
  -project HappySpeedUp.xcodeproj \
  -scheme HappySpeedUp \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

or just press ⌘U in Xcode.

## Architecture

The original `GameScene.m` mixed game rules with SpriteKit node manipulation.
In this port the rules are extracted into a pure, dependency-free
[`GameEngine`](HappySpeedUp/GameEngine.swift) so they can be unit-tested in
isolation. `GameScene` owns a `GameEngine` and only handles rendering and input.

| Swift file | Ported from | Notes |
|---|---|---|
| `GameEngine.swift` | `GameScene.m` logic | Pure speed/tool/score/collision rules (tested) |
| `GameConstants.swift` | scattered `const`s | Includes the `BASE_SPEEDY` 7.5→7 truncation quirk |
| `GameScene.swift` | `GameScene.{h,m}` | SpriteKit scene, drives the engine |
| `GameViewController.swift` | `GameViewController.{h,m}` | Hosts the scene, game delegate |
| `GameOverViewController.swift` | `GameOverViewController.{h,m}` | Game-over screen |
| `Player/Wall/Tool.swift` | `Player/Wall/Tool.{h,m}` | SKSpriteNode subclasses |
| `CommonUtil/BitmapUtil/TextureHelper.swift` | same | Shared helpers / texture slicing |
| `GameCenterUtil.swift` | `GameCenterUtil.{h,m}` | Modernised to the iOS 14 GKLeaderboard API |
| `MyADView.swift` | `MyADView.{h,m}` | House-ad banner |
| `MyUtils.swift` | `MyUtils.{h,m}` | Background-music wrapper |
| `AppDelegate.swift` | `AppDelegate.m` / `main.m` | App entry point |

## Tests

The `HappySpeedUpTests` target covers:

- **GameEngineTests** – tap direction/speed flip, speed-up cap & sign handling,
  speed-down floor guard, fly state, the tool countdown timer and reset,
  collision flag, and the wall/tool lifecycle predicates.
- **GameEngineLifecycleTests** – full eat → effect → countdown → reset cycles
  for each tool, the fly reset-animation handshake, repeated-tap alternation
  and the negative-sign / high-speed edge cases.
- **ScoringTests** – distance accumulation, the score-in-tens cadence, the
  cumulative distance formula and the 1500-point tool-spawn milestone.
- **CollisionTests** – the centre-50% hit-box intersection rules, including
  edge-touching, exact-match and enclosing cases.
- **WallTests / ToolTests** – node lifecycle predicates, movement and the
  spawn-roll distribution.
- **BitmapUtilTests** – aspect-ratio sizing with integer truncation.
- **TextureHelperTests** – sprite-sheet frame geometry (normalisation, row
  wrapping) and sequence selection.
- **GameSceneTests** – the scene's exposed state and its bridge to GameEngine.
- **GameConstantsTests** – locks the ported numeric constants and raw enum
  mappings.
- **BitmapUtilTests** – also covers the shared instance's player-width maths.
- **CommonUtilTests** – the shared screen-dimension holder.
- **MyUtilsTests** – background-music wrapper's safe no-audio behaviour.
- **GameCenterUtilTests** – availability, singleton and saved-score queue
  draining.
# iOS_HappySpeedUp-swift
