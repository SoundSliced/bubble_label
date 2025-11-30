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
            spacing: 45,
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
              Flexible(
                child: ExamplePage(animate: animate, useOverlay: useOverlay),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 15,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 12,
        children: [
          // A button that shows a bubble without overlay when tapped
          Builder(builder: (context) {
            return ElevatedButton(
              key: const Key('tap-show-no-overlay'),
              onPressed: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final bubbleContent = BubbleLabelContent(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('bubble 10px above - with no overlay'),
                  ),
                  childWidgetRenderBox: renderBox,
                  // bubble size adapts to its child
                  bubbleColor: Colors.green,
                  backgroundOverlayLayerOpacity: 0.0,
                  verticalPadding: 10,
                );

                BubbleLabel.show(
                  bubbleContent: bubbleContent,
                  animate: animate,
                );
              },
              child: const Text('Tap: show without overlay'),
            );
          }),

          // A button that shows a bubble when tapped
          Builder(builder: (context) {
            return ElevatedButton(
              key: const Key('tap-show'),
              onPressed: () {
                final renderBox = context.findRenderObject() as RenderBox;
                BubbleLabel.show(
                  bubbleContent: BubbleLabelContent(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Hello bubble!'),
                    ),
                    childWidgetRenderBox: renderBox,
                    // bubble size adapts to its child
                    bubbleColor: Colors.deepPurpleAccent,
                    backgroundOverlayLayerOpacity: useOverlay ? 0.3 : 0.0,
                  ),
                  animate: animate,
                );
              },
              child: const Text('Tap to show bubble'),
            );
          }),

          // An area that shows a bubble when long-pressed
          Builder(builder: (context) {
            return GestureDetector(
              key: const Key('longpress-area'),
              onLongPress: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final bubbleContent = BubbleLabelContent(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Long press bubble'),
                  ),
                  childWidgetRenderBox: renderBox,
                  verticalPadding: 25,
                  bubbleColor: Colors.orangeAccent,
                  backgroundOverlayLayerOpacity: useOverlay ? 0.25 : 0.0,
                  shouldActivateOnLongPressOnAllPlatforms: true,
                  dismissOnBackgroundTap: true,
                );

                BubbleLabel.show(
                  bubbleContent: bubbleContent,
                  animate: animate,
                );
              },
              child: Container(
                key: const Key('longpress-container'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Long-press here to show bubble 25px above',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap on background to dismiss',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // a bubble with a button as content
          Builder(builder: (context) {
            return GestureDetector(
              key: const Key('longpress-area-button'),
              onLongPress: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final bubbleContent = BubbleLabelContent(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          debugPrint('Button inside bubble tapped');
                        },
                        splashColor: Colors.blue,
                        highlightColor: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black12),
                            ),
                            padding: const EdgeInsets.all(6.0),
                            child: Text('Tap')),
                      ),
                    ),
                  ),
                  childWidgetRenderBox: renderBox,
                  bubbleColor: Colors.greenAccent,
                  backgroundOverlayLayerOpacity: useOverlay ? 0.25 : 0.0,
                  shouldActivateOnLongPressOnAllPlatforms: true,
                  dismissOnBackgroundTap: true,
                );

                BubbleLabel.show(
                  bubbleContent: bubbleContent,
                  animate: animate,
                );
              },
              child: Container(
                key: const Key('longpress-container-button'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey.shade300),
                ),
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Long-press area',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'A bubble with a button inside',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
