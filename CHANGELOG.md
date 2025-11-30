## 2.0.0 - 2025-11-30

### Highlights

- Major API update: bubble content positioning now derives from a `RenderBox` or an explicit `positionOverride` rather than passing screen coordinates. This simplifies using `BubbleLabel` from Widgets where you have a `BuildContext` or `RenderBox` rather than having to compute positions manually.
- Breaking change: removed explicit `labelWidth`/`labelHeight` and `childWidgetPosition`/`childWidgetSize` parameters. The bubble now adapts to the size of the `child` automatically and uses `childWidgetRenderBox`/`positionOverride` for anchor positioning.
- Added an `id` to `BubbleLabelContent` (a unique Xid) so callers can distinguish multiple activations when necessary.
- Added `dismissOnBackgroundTap` to allow background overlay taps to dismiss the bubble easily.
- Updated tests and example app to demonstrate the new API and usage patterns.

### Migration notes

- If your code used the previous `childWidgetPosition`/`childWidgetSize` fields, switch to providing a `RenderBox` using `childWidgetRenderBox` (e.g., using `context.findRenderObject()` in a `Builder`) or supply a `positionOverride: Offset(x,y)` to place the bubble explicitly.
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
