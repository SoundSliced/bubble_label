# bubble_label

A small Flutter package that shows a floating bubble label aligned to a child widget.

This provides a lightweight API to display a bubble-style label anchored to a widget, including optional background overlay and simple show/dismiss animations.

## Features
- Bubble label content that can be positioned and sized.
- Background overlay with configurable opacity.
- Simple show/dismiss animations.
- Easy to use static API: `BubbleLabel.show(...)` and `BubbleLabel.dismiss()`.

## Installation

Add the package as a dependency in your app's `pubspec.yaml` (for local development):

```yaml
dependencies:
  bubble_label:
    path: ../
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
                child: const Text('Bubble label content'),
                childWidgetPosition: position,
                childWidgetSize: size,
                bubbleColor: Colors.blueAccent,
                labelWidth: 140,
                labelHeight: 42,
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

`BubbleLabelContent` fields include:
- `child` — the content widget of the bubble.
- `bubbleColor` — bubble background color.
- `labelWidth`, `labelHeight` — size of the bubble.
- `childWidgetPosition`, `childWidgetSize` — required to anchor the bubble to the child widget.
- `backgroundOverlayLayerOpacity` — opacity for the background overlay.

## Example app

See the `example/` directory which demonstrates basic usage of the package.

## License

This project is licensed under the MIT License — see the `LICENSE` file for details.

## Repository

https://github.com/SoundSliced/bubble_label
