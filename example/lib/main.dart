import 'package:flutter/material.dart';
import 'package:bubble_label/bubble_label.dart';

void main() => runApp(const ExampleApp());

/// Example application used in this package's `example` folder.
///
/// Demonstrates typical usage of the `BubbleLabel` API.
class ExampleApp extends StatefulWidget {
  /// Creates the example application.
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  /// Whether the bubble overlay should ignore pointer events.
  ///
  /// When true (default), the overlay will ignore pointer events so the
  /// underlying widgets remain interactive.
  bool shouldIgnorePointer = true;

  /// Whether to animate show/dismiss operations in the example app.
  bool animate = true;

  /// Toggle to enable a background overlay behind the bubble.
  bool useOverlay = true;

  @override
  Widget build(BuildContext context) {
    return BubbleLabelController(
      shouldIgnorePointer: shouldIgnorePointer,
      child: MaterialApp(
        title: 'Bubble Label Example',
        home: Scaffold(
          appBar: AppBar(title: const Text('Bubble Label Example')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Allow bubble pointer events'),
                        value: shouldIgnorePointer == false,
                        onChanged: (val) {
                          setState(() => shouldIgnorePointer = !val);
                        },
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Animate'),
                        value: animate,
                        onChanged: (val) => setState(() => animate = val),
                      ),
                    ),
                    Expanded(
                      child: SwitchListTile(
                        title: const Text('Use overlay'),
                        value: useOverlay,
                        onChanged: (val) => setState(() => useOverlay = val),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: ExamplePage(animate: animate, useOverlay: useOverlay)),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      key: const Key('dismiss-button'),
                      onPressed: () => BubbleLabel.dismiss(animate: false),
                      child: const Text('Dismiss'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      key: const Key('dismiss-button-animate'),
                      onPressed: () => BubbleLabel.dismiss(animate: true),
                      child: const Text('Dismiss (animated)'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple page with buttons that call `BubbleLabel.show` to display
/// sample bubbles so users can try out the package behavior.
class ExamplePage extends StatelessWidget {
  /// Whether to animate show/dismiss operations in this example page.
  final bool animate;

  /// Whether the example shows a background overlay while the bubble is active.
  final bool useOverlay;

  /// Creates an `ExamplePage` used in the example app. It exposes two
  /// configurable options: [animate] and [useOverlay].
  const ExamplePage({super.key, this.animate = true, this.useOverlay = true});
  @override
  Widget build(BuildContext context) {
    // We put a few sample actions to demonstrate package features
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            return ElevatedButton(
              key: const Key('tap-show'),
              onPressed: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;

                BubbleLabel.show(
                  bubbleContent: BubbleLabelContent(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Hello bubble!'),
                    ),
                    childWidgetPosition: position,
                    childWidgetSize: size,
                    labelWidth: 140,
                    labelHeight: 40,
                    bubbleColor: Colors.deepPurpleAccent,
                    backgroundOverlayLayerOpacity: useOverlay ? 0.3 : 0.0,
                  ),
                  animate: animate,
                );
              },
              child: const Text('Tap to show bubble'),
            );
          }),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            return ElevatedButton(
              key: const Key('tap-show-no-overlay'),
              onPressed: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;

                BubbleLabel.show(
                  bubbleContent: BubbleLabelContent(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('No overlay'),
                    ),
                    childWidgetPosition: position,
                    childWidgetSize: size,
                    labelWidth: 180,
                    labelHeight: 44,
                    bubbleColor: Colors.green,
                    backgroundOverlayLayerOpacity: 0.0,
                    floatingVerticalPadding: 10,
                  ),
                  animate: animate,
                );
              },
              child: const Text('Tap: show without overlay'),
            );
          }),
          const SizedBox(height: 12),
          Builder(builder: (context) {
            return GestureDetector(
              key: const Key('longpress-area'),
              onLongPress: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;

                BubbleLabel.show(
                  bubbleContent: BubbleLabelContent(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Long press bubble'),
                    ),
                    childWidgetPosition: position,
                    childWidgetSize: size,
                    labelWidth: 160,
                    labelHeight: 48,
                    bubbleColor: Colors.orangeAccent,
                    backgroundOverlayLayerOpacity: useOverlay ? 0.25 : 0.0,
                    shouldActivateOnLongPressOnAllPlatforms: true,
                  ),
                  animate: animate,
                );
              },
              child: Container(
                key: const Key('longpress-container'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.blueGrey.shade50,
                child: const Text('Long-press here to show bubble'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
