## 1.0.1

* Version 1.0.1

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
