# bubble_label

A small Flutter package that shows a floating bubble label aligned to a child widget.

This provides a lightweight API to display a bubble-style label anchored to a widget, including optional background overlay and simple show/dismiss animations.

## Features
- Bubble label content that can be positioned and sized.
- Background overlay with configurable opacity.
- Simple show/dismiss animations.
- Easy to use static API: `BubbleLabel.show(...)` and `BubbleLabel.dismiss()`.


## Example app

See the `example/` directory which demonstrates basic usage of the package.

![Bubble label example GIF](https://raw.githubusercontent.com/SoundSliced/bubble_label/main/example/assets/example.gif)

## Installation

Add the package as a dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  bubble_label: ^3.0.0
```

> When using this package from outside the repository (published), replace the path dependency with a hosted version.

## Basic usage

Wrap your app's root widget with `BubbleLabelController` so the overlay can be displayed on top of your UI. A minimal usage looks like this:

```dart
import 'package:flutter/material.dart';
import 'package:bubble_label/bubble_label.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BubbleLabelController(
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Your app')),
        ),
      ),
    );
  }
}
```

Use `BubbleLabel.show(...)` to present a bubble and provide a `BubbleLabelContent` containing the bubble content and position information. For a full runnable example, see the `example/` directory.

Example app features
--------------------
- Toggle `Allow bubble pointer events` (controls `BubbleLabelController.shouldIgnorePointer`). When this is off the bubble ignores taps; turning it off allows the bubble to receive pointer events.
- Toggle `Animate` (show/dismiss animations — uses the `animate` parameter when calling `BubbleLabel.show` or `BubbleLabel.dismiss`).
- Toggle `Use overlay` — when off, only the bubble is shown without any background overlay.
- Buttons:
  - Show — demonstrates a standard bubble with overlay (if enabled).
  - Tap: show without overlay — demonstrates a bubble with no overlay (explicitly sets overlay to 0.0).
  - Dismiss — dismisses the bubble immediately (`animate: false`).
  - Dismiss (animated) — dismisses the bubble with animation (`animate: true`).
  - Long-press area — long-pressing this area will call `BubbleLabel.show` with `shouldActivateOnLongPressOnAllPlatforms` set; you can toggle `Use overlay` and `Animate` to see the effect.

```

## API
Key public pieces of the API:

- `BubbleLabelController` — a top-level widget that must wrap the application and allows the bubble to render above other widgets.
- `BubbleLabel.show(...)` — show the bubble overlay with provided content and parameters. Passing an `anchorKey` lets the bubble automatically derive the anchor `RenderBox`, so you can skip manual `context.findRenderObject()` calls; alternatively you can supply a `BubbleLabelContent.positionOverride`. Exactly one of those anchor inputs must be provided—supplying both is disallowed.
- `BubbleLabel.dismiss()` — dismiss the bubble.
- `BubbleLabel.isActive` — boolean property indicating whether a bubble is currently active.
- `BubbleLabel.controller` — access to the injected controller instance for programmatic inspection or updates (advanced use).

`BubbleLabelContent` fields include (defaults shown where applicable):
- `child` — the content widget of the bubble.
- `bubbleColor` — bubble background color.
- The bubble now adapts to the `child` size; explicit `labelWidth`/`labelHeight` are removed.
- `_childWidgetRenderBox` — internal storage for the anchor widget's `RenderBox` when an `anchorKey` is supplied to `BubbleLabel.show`. The bubble size/position still honors `positionOverride` when you need to anchor to specific coordinates instead.
- `positionOverride` — optional explicit `Offset` to anchor the bubble directly.
- `backgroundOverlayLayerOpacity` — opacity for the background overlay.

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

Advanced usage
```
// Wrap your app and customize pointer behaviour
BubbleLabelController(
  shouldIgnorePointer: false, // set to false so the bubble receives pointer events
  child: MaterialApp(...),
);

// Show a bubble automatically anchored to the widget that triggered it
final showButtonKey = GlobalKey();
ElevatedButton(
  key: showButtonKey,
  onPressed: () {
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('No overlay'),
        bubbleColor: Colors.green,
        backgroundOverlayLayerOpacity: 0.0,
        verticalPadding: 10, // 10 px above the anchor
      ),
      anchorKey: showButtonKey,
      animate: true,
    );
  },
  child: const Text('Show without overlay'),
);

// Show a bubble with an explicit screen offset anchor (use `positionOverride`)
BubbleLabel.show(
  bubbleContent: BubbleLabelContent(
    child: const Text('Position override bubble'),
    positionOverride: Offset(200, 150), // anchor at (200,150) screen coords
  ),
);
```

Keep each `GlobalKey` as a long-lived field (for example, on your widget's state) and re-use it when calling `BubbleLabel.show`. That way the anchor `RenderBox` is stable, you avoid extra builders, and the bubble can always resolve the correct position.
## Changelog

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
