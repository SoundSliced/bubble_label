## 4.0.0 - 2025-12-12

### BREAKING CHANGES

- **Removed `BubbleLabelController` widget requirement**: The package now uses Flutter's native `Overlay` system, eliminating the need to wrap your app with `BubbleLabelController`. Simply use `MaterialApp`, `CupertinoApp`, or any widget tree with an `Overlay`.

- **Migrated from Stack-based to Overlay-based rendering**: The bubble now uses native `OverlayEntry` for better performance and cleaner architecture.

- **Moved `shouldIgnorePointer` from `BubbleLabelController` to `BubbleLabelContent`**: Instead of setting `shouldIgnorePointer` on the controller widget, you now set it per-bubble in `BubbleLabelContent`. This allows different bubbles to have different pointer behaviors.

### Migration from v3.x

Before (v3.x):
```dart
BubbleLabelController(
  shouldIgnorePointer: false,
  child: MaterialApp(...),
);
```

After (v4.0.0):
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

### New Features

- **`shouldIgnorePointer` property on `BubbleLabelContent`**: Control whether the bubble content receives pointer events. When `true` (default), taps pass through; when `false`, interactive widgets inside the bubble (e.g., buttons) can be tapped.

- **`BubbleLabel.updateContent()` method**: Reactively update bubble properties while it's displayed without dismissing and re-showing. Useful for toggling `shouldIgnorePointer` or changing colors on the fly.

- **`BubbleLabel.tapRegionGroupId`**: Exposes the TapRegion group ID so external widgets can join the bubble's "inside" detection. Wrap widgets with `TapRegion(groupId: BubbleLabel.tapRegionGroupId, child: ...)` to prevent them from triggering `dismissOnBackgroundTap`.

- **`onTapInside` and `onTapOutside` callbacks**: Optional callbacks in `BubbleLabelContent` that fire when taps are detected inside or outside the bubble. Useful for visual feedback, analytics, or custom logic.

### Improvements

- **Responsive bubble positioning**: The bubble now dynamically tracks the anchor widget's position. When the layout changes (e.g., a snackbar appears and shifts content), the bubble follows its anchor widget instead of staying at the original position.

- **TapRegion inside/outside detection**: Switched from `IgnorePointer` to `AbsorbPointer` so TapRegion correctly detects whether taps are inside or outside the bubble even when pointer events are ignored.

- **Cancellable dismiss timer**: Replaced `await Future.delayed()` with a cancellable `Timer` to prevent race conditions when multiple dismiss calls happen in quick succession.

- **No BuildContext across async gaps**: Overlay resolution now happens before any async operations to avoid lint warnings and potential issues with disposed widgets.

- **Removed debug prints**: All `debugPrint` statements removed from the library for cleaner production logs.

- **Hybrid validation system**: Uses debug assertions in development mode and FlutterError in production for better overlay detection feedback.

### Example App Updates

- Updated to work without `BubbleLabelController` wrapper.
- Added visual feedback banner showing "Tap INSIDE" or "Tap OUTSIDE" when tapping bubbles with callbacks enabled.
- Toggle widgets are now wrapped with `TapRegion` using the bubble's group ID to demonstrate the feature.
- Long-press bubble now demonstrates `onTapInside` and `onTapOutside` callbacks.

---

## 3.0.1 - 2025-12-05
- example.gif size reduced to pass Pub.dev score Documentation analysis

## 3.0.0 - 2025-12-05

### Enhancements and BREAKING CHANGE for boilerplate reduction purposes

- BoilerPlate reduction: `BubbleLabel.show` now automatically resolves the anchor `RenderBox` when user passes an `anchorKey`, so manual `context.findRenderObject()` calls are no longer necessary.
- Added stricter input validation: each call to `BubbleLabel.show` must provide exactly one anchor source—either supply an `anchorKey` to derive the widget's `RenderBox` *or* give a `BubbleLabelContent.positionOverride`. Passing both at the same time is disallowed and will assert during development.

## 2.0.2 - 2025-11-30

### Fixes

- Documentation: Updated README to use relative image paths so pub.dev renders images inline.
- Pub.dev page: Added `screenshots` to `pubspec.yaml` so the GIF appears in the Screenshots section; added `topics` for discoverability.

## 2.0.1

* updated pubspec.yaml and README files

## 2.0.0 - 2025-11-30

### Highlights

- Major API update: bubble content positioning now derives from a `RenderBox` or an explicit `positionOverride` rather than passing screen coordinates. This simplifies using `BubbleLabel` from Widgets where you have a `BuildContext` or `RenderBox` rather than having to compute positions manually.
- Breaking change: removed explicit `labelWidth`/`labelHeight` and `childWidgetPosition`/`childWidgetSize` parameters. The bubble now adapts to the size of the `child` automatically and uses `childWidgetRenderBox`/`positionOverride` for anchor positioning.
- Added an `id` to `BubbleLabelContent` (a unique Xid) so callers can distinguish multiple activations when necessary.
- Added `dismissOnBackgroundTap` to allow background overlay taps to dismiss the bubble easily.
- Updated tests and example app to demonstrate the new API and usage patterns.

### Migration notes

- If your code used the previous `childWidgetPosition`/`childWidgetSize` fields, switch to providing a `RenderBox` using `childWidgetRenderBox` (e.g., using `context.findRenderObject()` in a `Builder`), supply a `positionOverride: Offset(x,y)`, or use the new `anchorKey` option on `BubbleLabel.show` to resolve the anchor automatically.
- Remove any code that passed `labelWidth`/`labelHeight` — the bubble automatically sizes to the `child` content. Use `Container`, `SizedBox`, or other layout widgets inside the `child` to control the bubble size if you need explicit dimensions.
- If needed, you can still horizontally/vertically offset the bubble via the `floatingVerticalPadding` parameter in `BubbleLabelContent`.

### Other changes

- Small animation improvements to opening/closing and fade durations.
- Clean-up: refactored internal state handling and simplified the public API surface.


## 1.0.1 - Documentation and test improvements (2025-11-25)

- Added comprehensive dartdoc comments for public API elements to improve discoverability and meet pub.dev documentation requirements.
- Enabled the `public_member_api_docs` lint rule in `analysis_options.yaml` to help maintain documentation coverage.
- Improved README formatting and clarified usage examples; ensured the `example/` app demonstrates pointer, overlay, and animation toggles.
- Confirmed unit tests cover the main behaviors and updated them where required to ensure stable tests for animation timings and immediate (non-animated) dismissals.

## 1.0.0 - Initial stable release (2025-11-24)

- Added `BubbleLabelController` which provides a global overlay for the bubble label.
- Implemented `BubbleLabel.show(...)` and `BubbleLabel.dismiss()` to control the bubble presentation and animation.
- Added `BubbleLabelContent` to define bubble size, color, content and the anchor position/size.
- Background overlay support with configurable opacity and show/hide animations.
- Added `example/` app demonstrating basic usage (tap a button to show a bubble).
 - Updated `example/` app to demonstrate advanced usage: long-press activation, disabling overlay, animation toggles and ignoring pointer behavior.
 - Improved tests to cover additional behaviors: overlay opacity, ignore pointer behavior, long-press activation, and animation timing.
 - Updated `example/` app to include UI dismissal options (immediate & animated) and toggles to control show/dismiss behavior.
	- `example/` app demonstrates basic usage. Run with: `cd example && flutter run`.

## 0.0.1 - Pre-release

- Initial release and simple proof of concept.
