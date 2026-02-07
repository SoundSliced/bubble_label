# bubble_label

A small Flutter package that shows a floating bubble label aligned to a child widget.

This provides a lightweight API to display a bubble-style label anchored to a widget, including optional background overlay and simple show/dismiss animations.

## Features
- **Simplified API (v5.0.0)** — No GlobalKey boilerplate needed! Just pass `context` and the bubble anchors to that widget automatically.
- **Transform-aware positioning (v5.1.0)** — Bubbles correctly position themselves even when ancestor widgets contain transforms like `Transform.scale`, `ForcePhoneSizeOnWeb`, or `FittedBox`.
- Bubble label content that can be positioned and sized.
- Background overlay with configurable opacity.
- Simple show/dismiss animations.
- Easy to use static API: `BubbleLabel.show(...)` and `BubbleLabel.dismiss()`.
- Works reliably in complex widget trees with robust overlay detection.


## Example app

See the `example/` directory which demonstrates basic usage of the package.

![Bubble label example GIF](https://raw.githubusercontent.com/SoundSliced/bubble_label/main/example/assets/example.gif)

## Installation

Add the package as a dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  bubble_label: ^6.0.0
```

> When using this package from outside the repository (published), replace the path dependency with a hosted version.

## Basic usage

No wrapper widget is required! The package uses Flutter's native `Overlay` system, which is automatically provided by `MaterialApp`, `CupertinoApp`, or any widget tree that includes an `Overlay`.

**Simplest usage (v5.0.0+):**

```dart
import 'package:flutter/material.dart';
import 'package:bubble_label/bubble_label.dart';

// In your widget's build method:
Builder(
  builder: (context) {
    return ElevatedButton(
      onPressed: () {
        BubbleLabel.show(
          context: context,  // Uses this button as anchor!
          bubbleContent: BubbleLabelContent(
            child: const Text('Hello bubble!'),
            bubbleColor: Colors.blue,
          ),
        );
      },
      child: const Text('Show Bubble'),
    );
  },
);
```

That's it! No `GlobalKey` needed. The bubble will appear above the button that was tapped.

**With explicit anchor (when needed):**

```dart
final myKey = GlobalKey();

ElevatedButton(
  key: myKey,
  onPressed: () {
    BubbleLabel.show(
      context: context,
      anchorKey: myKey,  // Anchor to a specific widget
      bubbleContent: BubbleLabelContent(
        child: const Text('Anchored bubble'),
      ),
    );
  },
  child: const Text('Show'),
);
```

For a full runnable example, see the `example/` directory.

Example app features
--------------------
- Toggle `Allow bubble pointer events` — controls whether the bubble receives pointer events (sets `shouldIgnorePointer` on `BubbleLabelContent`). When this is off the bubble ignores taps; turning it on allows the bubble to receive pointer events.
- Toggle `Animate` (show/dismiss animations — uses the `animate` parameter when calling `BubbleLabel.show` or `BubbleLabel.dismiss`).
- Toggle `Use overlay` — when off, only the bubble is shown without any background overlay.
- Buttons:
  - Show — demonstrates a standard bubble with overlay (if enabled).
  - Tap: show without overlay — demonstrates a bubble with no overlay (explicitly sets overlay to 0.0).
  - Dismiss — dismisses the bubble immediately (`animate: false`).
  - Dismiss (animated) — dismisses the bubble with animation (`animate: true`).
  - Long-press area — long-pressing this area will call `BubbleLabel.show` with `shouldActivateOnLongPressOnAllPlatforms` set; you can toggle `Use overlay` and `Animate` to see the effect.

## API
Key public pieces of the API:

- `BubbleLabel.show(...)` — show the bubble overlay with provided content and parameters. **`context` is required** and serves two purposes: (1) finding the Overlay widget, and (2) as the default anchor for positioning the bubble. If you want to anchor to a different widget, pass an `anchorKey`. Alternatively, use `BubbleLabelContent.positionOverride` for explicit screen coordinates.
- `BubbleLabel.dismiss()` — dismiss the bubble.
- `BubbleLabel.isActive` — boolean property indicating whether a bubble is currently active.
- `BubbleLabel.controller` — access to the injected controller instance for programmatic inspection or updates (advanced use).
- `BubbleLabel.updateContent(...)` — update the active bubble's content dynamically without dismissing it (new in v4.0.0).
- `BubbleLabel.tapRegionGroupId` — the group ID used by the bubble's `TapRegion`, allowing external widgets to be considered "inside" the bubble (new in v4.0.0).

`BubbleLabelContent` fields include (defaults shown where applicable):
- `child` — the content widget of the bubble.
- `bubbleColor` — bubble background color.
- The bubble now adapts to the `child` size; explicit `labelWidth`/`labelHeight` are removed.
- `_childWidgetRenderBox` — internal storage for the anchor widget's `RenderBox` when an `anchorKey` is supplied to `BubbleLabel.show`. The bubble size/position still honors `positionOverride` when you need to anchor to specific coordinates instead.
- `positionOverride` — optional explicit `Offset` to anchor the bubble directly.
- `backgroundOverlayLayerOpacity` — opacity for the background overlay.
- `shouldIgnorePointer` — when `true`, pointer events pass through the bubble content (new in v4.0.0).
- `onTapInside` — callback triggered when a tap is detected inside the bubble (new in v4.0.0).
- `onTapOutside` — callback triggered when a tap is detected outside the bubble (new in v4.0.0).

Optional parameters you might find handy:
- `bubbleColor` — use to customize bubble color.
- `backgroundOverlayLayerOpacity` — use to dim the underlying UI; set to `0.0` to disable.
- `animate` flag in `show()` and `dismiss()` — pass `false` during testing or if you want immediate effect.

Dismissing the bubble
```
// programmatic dismissal, immediate
BubbleLabel.dismiss(animate: false);

// programmatic dismissal, with animation
BubbleLabel.dismiss(animate: true);

// The example app has dedicated buttons showing these two dismissal modes.
```
 - `floatingVerticalPadding` — adjust the vertical offset between the child widget and bubble.
 - `shouldActivateOnLongPressOnAllPlatforms` — a hint to indicate that the bubble was triggered by long-press; you can set this to true when using long-press activation.


To run the example application locally:

```bash
cd example
flutter run
```

Testing & debugging tip: The package exposes a small `controller` that can be inspected from tests to assert active bubble state or properties.

### Important API changes in v2.0.0
- Removed `labelWidth`/`labelHeight`: the bubble adapts to the `child` size automatically.
- Removed `childWidgetPosition`/`childWidgetSize` — instead rely on the anchor automatically resolved from the `anchorKey` you pass to `BubbleLabel.show`, or fall back to `positionOverride` when specifying explicit screen coordinates.
- `BubbleLabelContent` now includes an `id` and `dismissOnBackgroundTap` to enable automatic background tap dismissals.

### Migrating from v4.x to v5.0.0

**Before (v4.x):**
```dart
final myKey = GlobalKey();
ElevatedButton(
  key: myKey,
  onPressed: () {
    BubbleLabel.show(
      anchorKey: myKey,
      bubbleContent: BubbleLabelContent(
        child: Text('Hello'),
      ),
    );
  },
  child: Text('Show'),
);
```

**After (v5.0.0) - Simplified:**
```dart
Builder(
  builder: (context) {
    return ElevatedButton(
      onPressed: () {
        BubbleLabel.show(
          context: context, // Uses this button as anchor!
          bubbleContent: BubbleLabelContent(
            child: Text('Hello'),
          ),
        );
      },
      child: Text('Show'),
    );
  },
);
```

**After (v5.0.0) - With explicit anchorKey (optional):**
```dart
BubbleLabel.show(
  context: context,  // Required for overlay lookup
  anchorKey: myKey,  // Optional: anchor to a different widget
  bubbleContent: BubbleLabelContent(
    child: Text('Hello'),
  ),
);
```

### Migrating from v3.x to v4.0.0

**Before (v3.x):**
```dart
BubbleLabelController(
  shouldIgnorePointer: false,
  child: MaterialApp(...),
);
```

**After (v4.0.0):**
```dart
MaterialApp(...); // No wrapper needed!

BubbleLabel.show(
  bubbleContent: BubbleLabelContent(
    child: Text('Hello'),
    shouldIgnorePointer: false, // Now set per-bubble
  ),
  anchorKey: myKey,
);
```

Advanced usage
```dart
// Simplest usage: context widget becomes the anchor (no GlobalKey needed!)
Builder(
  builder: (context) {
    return ElevatedButton(
      onPressed: () {
        BubbleLabel.show(
          context: context,  // This button is the anchor
          bubbleContent: BubbleLabelContent(
            child: const Text('No overlay'),
            bubbleColor: Colors.green,
            backgroundOverlayLayerOpacity: 0.0,
            verticalPadding: 10, // 10 px above the anchor
          ),
          animate: true,
        );
      },
      child: const Text('Show without overlay'),
    );
  },
);

// With explicit anchorKey (when you need to anchor to a different widget)
final showButtonKey = GlobalKey();
ElevatedButton(
  key: showButtonKey,
  onPressed: () {
    BubbleLabel.show(
      context: context,
      anchorKey: showButtonKey,  // Anchor to this specific widget
      bubbleContent: BubbleLabelContent(
        child: const Text('Anchored to key'),
      ),
    );
  },
  child: const Text('Show'),
);

// Show a bubble with an explicit screen offset anchor (use `positionOverride`)
BubbleLabel.show(
  context: context,
  bubbleContent: BubbleLabelContent(
    child: const Text('Position override bubble'),
    positionOverride: Offset(200, 150), // anchor at (200,150) screen coords
  ),
);
```

When using the simplified context-as-anchor approach, wrap your widget in a `Builder` to get a context that refers to that specific widget. If you need dynamic position tracking (e.g., the anchor widget moves), use a `GlobalKey` instead.

### Reactive Updates (v4.0.0+)

Use `BubbleLabel.updateContent()` to dynamically update the bubble while it's displayed:

```dart
// Update a property while the bubble is open
BubbleLabel.updateContent(shouldIgnorePointer: true);
```

### TapRegion Group Integration (v4.0.0+)

If you have external widgets (like toggles or controls) that should be considered "inside" the bubble for tap detection purposes, wrap them with a `TapRegion` using the bubble's group ID:

```dart
TapRegion(
  groupId: BubbleLabel.tapRegionGroupId,
  child: YourControlWidget(),
)
```

Taps on these wrapped widgets won't trigger `onTapOutside` or dismiss the bubble via `dismissOnBackgroundTap`.

### Tap Event Callbacks (v4.0.0+)

Use `onTapInside` and `onTapOutside` callbacks for custom tap handling:

```dart
BubbleLabelContent(
  child: const Text('Interactive bubble'),
  onTapInside: (details) {
    // Handle tap inside bubble
  },
  onTapOutside: (details) {
    // Handle tap outside bubble
  },
)
```

## Changelog

### 5.1.0 (2026-01-06) - Transform-Aware Positioning

**Bug Fixes:**
- **Fixed bubble positioning with ancestor transforms** — Bubbles now correctly position themselves when the widget tree contains transforms such as `Transform.scale`, `ForcePhoneSizeOnWeb` (from `flutter_web_frame`), or `FittedBox`. Both the anchor position and visual size are computed relative to the Overlay's coordinate system.
- **Fixed bubble replacement during transforms** — When showing a new bubble while one is already active, the Overlay's RenderBox reference is now correctly preserved.
- **Fixed crash when toggling transforms with active bubble** — Added safety checks for `RenderBox.attached` to prevent crashes when the widget tree is rebuilt while a bubble is active.

**Example App:**
- Added `Transform.scale` and `ForcePhoneSizeOnWeb` toggles to demonstrate transform-aware positioning.

---

### 5.0.0 (2026-01-06) - Simplified API with Required Context

**BREAKING CHANGES:**
- **`context` is now a required parameter in `BubbleLabel.show()`** — This ensures reliable overlay detection in complex widget trees.
- **`anchorKey` is now optional** — The `context` widget is used as the anchor by default. Pass `anchorKey` only when you need to anchor to a different widget.

**New Features:**
- **Simplified API** — No more GlobalKey boilerplate for simple use cases! Just pass `context` and the bubble anchors to that widget.
- **Context-as-anchor** — When no `anchorKey` or `positionOverride` is provided, the widget from `context` becomes the anchor.

**Improvements:**
- **Robust overlay lookup strategy** — Now tries `rootOverlay: true` first, then falls back to `rootOverlay: false` for maximum compatibility.
- **Better error messages** — Clearer guidance when overlay detection fails, with specific solutions.

**Migration from v4.x:**

```dart
// Before (v4.x)
BubbleLabel.show(
  anchorKey: myKey,
  bubbleContent: BubbleLabelContent(...),
);

// After (v5.0.0)
BubbleLabel.show(
  context: context,  // Now required!
  anchorKey: myKey,
  bubbleContent: BubbleLabelContent(...),
);
```

### 4.0.0 (2025-12-12) - Overlay-based Implementation & Enhanced Interactivity

**BREAKING CHANGES:**
- **Removed `BubbleLabelController` widget requirement** — The package now uses Flutter's native `Overlay` system, eliminating the need to wrap your app with a custom controller widget.
- **Migrated from Stack-based to Overlay-based rendering** — Uses native `OverlayEntry` for better performance.
- **Moved `shouldIgnorePointer` from `BubbleLabelController` to `BubbleLabelContent`** — Now set per-bubble instead of globally.

**New Features:**
- **`shouldIgnorePointer` property** on `BubbleLabelContent` — control whether pointer events pass through the bubble content.
- **`onTapInside` / `onTapOutside` callbacks** on `BubbleLabelContent` — respond to tap events inside or outside the bubble.
- **`BubbleLabel.updateContent()`** — dynamically update the active bubble's content without dismissing it.
- **`BubbleLabel.tapRegionGroupId`** — exposed group ID allowing external widgets to be considered "inside" the bubble for tap detection.

**Improvements:**
- Replaced `IgnorePointer` with `AbsorbPointer` for proper `TapRegion` hit testing.
- Dismiss animation now uses a cancellable `Timer` to prevent race conditions.
- Fixed BuildContext async gap lint warning in dismiss flow.
- Removed all `debugPrint` statements from the library.
- Hybrid validation system for better overlay detection feedback.

### 3.0.0 (2025-12-05)

- Boilerplate reduction: `BubbleLabel.show` now automatically resolves the anchor `RenderBox` when passing an `anchorKey`.
- Stricter input validation: must provide exactly one anchor source (`anchorKey` or `positionOverride`).

### 2.0.0 (2025-11-30)

- Major API update: rendering and anchoring simplified via `childWidgetRenderBox` and `positionOverride`; automatic bubble sizing to `child`.
- Added `id` to `BubbleLabelContent` and `dismissOnBackgroundTap` option to easily dismiss overlay by tapping.
- Updated example app and tests to reflect the new API and control toggles.

### 1.0.1 (2025-11-25)

- Added public documentation (dartdoc) for public API types and members.
- Enabled `public_member_api_docs` lint in `analysis_options.yaml` to enforce documentation for public members.
- Cleaned up README formatting and clarified example usage. 
- Verified tests for overlay opacity, pointer behavior, and animations.


## License

This project is licensed under the MIT License — see the `LICENSE` file for details.

## Repository

https://github.com/SoundSliced/bubble_label
