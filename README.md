# bubble_label

A small Flutter package that shows a floating bubble label aligned to a child widget.

This provides a lightweight API to display a bubble-style label anchored to a widget, including optional background overlay and simple show/dismiss animations.

## Features
- Bubble label content that can be positioned and sized.
- Background overlay with configurable opacity.
- Simple show/dismiss animations.
- Easy to use static API: `BubbleLabel.show(...)` and `BubbleLabel.dismiss()`.

## Installation

Add the package as a dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  bubble_label: ^1.0.0
```

> When using this package from outside the repository (published), replace the path dependency with a hosted version.

## Basic usage

Wrap your app's root widget with `BubbleLabelController` so the overlay can be displayed on top of your UI:

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
          body: const ExamplePage(),
        ),
      ),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () {
            // obtain button position and size
            final renderBox = context.findRenderObject() as RenderBox;
            final position = renderBox.localToGlobal(Offset.zero);
            final size = renderBox.size;

            // show the bubble label
              BubbleLabel.show(
                bubbleContent: BubbleLabelContent(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),

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
                    child: Text('Hello bubble!'),
                  ),
                  childWidgetPosition: position,
                  childWidgetSize: size,
                  labelWidth: 140,
                  labelHeight: 40,
                  bubbleColor: Colors.deepPurpleAccent,
                  backgroundOverlayLayerOpacity: 0.3,
                ),
              );
          },
          child: const Text('Tap to show bubble'),
        );
      }),
    );
  }
}

```

## API
Key public pieces of the API:

- `BubbleLabelController` — a top-level widget that must wrap the application and allows the bubble to render above other widgets.
- `BubbleLabel.show(bubbleContent: BubbleLabelContent(...))` — show the bubble overlay with provided content and parameters.
- `BubbleLabel.dismiss()` — dismiss the bubble.
- `BubbleLabel.isActive` — boolean property indicating whether a bubble is currently active.
- `BubbleLabel.controller` — access to the injected controller instance for programmatic inspection or updates (advanced use).

`BubbleLabelContent` fields include (defaults shown where applicable):
- `child` — the content widget of the bubble.
- `bubbleColor` — bubble background color.
- `labelWidth`, `labelHeight` — size of the bubble.
- `childWidgetPosition`, `childWidgetSize` — required to anchor the bubble to the child widget.
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

## Example app

See the `example/` directory which demonstrates basic usage of the package.

To run the example application locally:

```bash
cd example
flutter run
```

Testing & debugging tip: The package exposes a small `controller` that can be inspected from tests to assert active bubble state or properties.

Advanced usage
```
// Wrap your app and customize pointer behaviour
BubbleLabelController(
  shouldIgnorePointer: false, // set to false so the bubble receives pointer events
  child: MaterialApp(...),
);

// Show a bubble with no overlay and a custom vertical offset
BubbleLabel.show(
  bubbleContent: BubbleLabelContent(
    child: Text('No overlay'),
    childWidgetPosition: position,
    childWidgetSize: size,
    labelWidth: 180,
    labelHeight: 44,
    bubbleColor: Colors.green,
    backgroundOverlayLayerOpacity: 0.0,
    floatingVerticalPadding: 10,
  ),
  animate: true,
);

// Show a bubble triggered from a long press (e.g., inside a GestureDetector)
BubbleLabel.show(
  bubbleContent: BubbleLabelContent(
    child: Text('Long press bubble'),
    childWidgetPosition: position,
    childWidgetSize: size,
    shouldActivateOnLongPressOnAllPlatforms: true,
  ),
);
```

## License

This project is licensed under the MIT License — see the `LICENSE` file for details.

## Repository

https://github.com/SoundSliced/bubble_label
