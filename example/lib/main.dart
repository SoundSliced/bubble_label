import 'package:flutter/material.dart';
import 'package:bubble_label/bubble_label.dart';
import 'package:s_toggle/s_toggle.dart';

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

  /// Visual feedback message for tap inside/outside detection
  String? _tapFeedback;

  void _showTapFeedback(String message, Color color) {
    setState(() => _tapFeedback = message);
    // Auto-clear after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _tapFeedback = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubble Label Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bubble Label Example'),
          // Show tap feedback in the app bar
          bottom: _tapFeedback != null
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    color: _tapFeedback!.contains('INSIDE')
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Text(
                      _tapFeedback!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _tapFeedback!.contains('INSIDE')
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: Column(
          spacing: 45,
          children: [
            /// Configuration toggles - wrapped in TapRegion to be considered
            /// "inside" the bubble (tapping here won't dismiss the bubble)
            TapRegion(
              groupId: BubbleLabel.tapRegionGroupId,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 80,
                  child: Column(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// Toggle to allow/disallow bubble pointer events
                      Flexible(
                        child: Row(
                          spacing: 8,
                          children: [
                            const Text('Allow bubble pointer events'),
                            SToggle(
                              size: 40,
                              onColor: Colors.green,
                              offColor: Colors.red,
                              value: shouldIgnorePointer == false,
                              onChange: (val) {
                                setState(() => shouldIgnorePointer = !val);
                                // Update the active bubble if one is showing
                                BubbleLabel.updateContent(
                                  shouldIgnorePointer: shouldIgnorePointer,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      /// Toggle to enable/disable animation
                      Flexible(
                        child: Row(
                          spacing: 8,
                          children: [
                            const Text('Animate'),
                            SToggle(
                              size: 40,
                              onColor: Colors.green,
                              offColor: Colors.red,
                              value: animate,
                              onChange: (val) => setState(() => animate = val),
                            ),
                          ],
                        ),
                      ),

                      /// Toggle to enable/disable overlay
                      Flexible(
                        child: Row(
                          spacing: 8,
                          children: [
                            const Text('Use overlay'),
                            SToggle(
                              size: 40,
                              onColor: Colors.green,
                              offColor: Colors.red,
                              value: useOverlay,
                              onChange: (val) =>
                                  setState(() => useOverlay = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            /// The main example page with buttons to show bubbles.
            Flexible(
              child: ExamplePage(
                animate: animate,
                useOverlay: useOverlay,
                shouldIgnorePointer: shouldIgnorePointer,
                onTapFeedback: _showTapFeedback,
              ),
            ),

            /// Dismiss buttons
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
    );
  }
}

/// A simple page with buttons that call `BubbleLabel.show` to display
/// sample bubbles so users can try out the package behavior.
class ExamplePage extends StatefulWidget {
  /// Whether to animate show/dismiss operations in this example page.
  final bool animate;

  /// Whether the example shows a background overlay while the bubble is active.
  final bool useOverlay;

  /// Whether the background overlay should ignore pointer events.
  final bool shouldIgnorePointer;

  /// Callback to show visual feedback for tap inside/outside.
  final void Function(String message, Color color)? onTapFeedback;

  /// Creates an `ExamplePage` used in the example app. It exposes two
  /// configurable options: [animate] and [useOverlay].
  const ExamplePage({
    super.key,
    this.animate = true,
    this.useOverlay = true,
    this.shouldIgnorePointer = true,
    this.onTapFeedback,
  });

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final noOverlayKey = GlobalKey();
  final bubbleKey = GlobalKey();
  final longPressKey = GlobalKey();
  final bubbleButtonKey = GlobalKey();
  final positionOverrideButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 12,
        children: [
          /// A simple button that shows a bubble when tapped.
          ElevatedButton(
            key: bubbleKey,
            onPressed: () {
              BubbleLabel.show(
                bubbleContent: BubbleLabelContent(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Hello bubble!',
                        style: TextStyle(color: Colors.white)),
                  ),
                  bubbleColor: Colors.deepPurpleAccent,
                  backgroundOverlayLayerOpacity: widget.useOverlay ? 0.3 : 0.0,
                ),
                animate: widget.animate,
                anchorKey: bubbleKey,
              );
            },
            child: const Text('show bubble'),
          ),

          /// A simple button that shows a bubble without overlay when tapped.
          ElevatedButton(
            key: noOverlayKey,
            onPressed: () {
              final bubbleContent = BubbleLabelContent(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'bubble 25px above Anchor widget',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                bubbleColor: Colors.green,
                backgroundOverlayLayerOpacity: 0.0,
                verticalPadding: 25,
              );

              BubbleLabel.show(
                bubbleContent: bubbleContent,
                animate: widget.animate,
                anchorKey: noOverlayKey,
              );
            },
            child: const Text('Bubble 25px above'),
          ),

          /// A long-press area that shows a bubble when long-pressed.
          GestureDetector(
            key: longPressKey,
            onLongPress: () {
              final bubbleContent = BubbleLabelContent(
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('Long press bubble - tap inside/outside!'),
                ),
                bubbleColor: const Color.fromARGB(255, 239, 246, 35),
                backgroundOverlayLayerOpacity: widget.useOverlay ? 0.25 : 0.0,
                shouldActivateOnLongPressOnAllPlatforms: true,
                dismissOnBackgroundTap: true,
                // Visual feedback callbacks for tap detection
                onTapInside: (details) {
                  widget.onTapFeedback?.call(
                    '✅ Tap INSIDE bubble detected!',
                    Colors.green,
                  );
                },
                onTapOutside: (details) {
                  widget.onTapFeedback?.call(
                    '⚠️ Tap OUTSIDE bubble detected!',
                    Colors.orange,
                  );
                },
              );

              BubbleLabel.show(
                bubbleContent: bubbleContent,
                animate: widget.animate,
                anchorKey: longPressKey,
              );
            },
            child: Container(
              key: const Key('longpress-container'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    'Long-press to show bubble',
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
          ),

          /// A long-press area that shows a bubble with a button inside when long-pressed.
          GestureDetector(
            key: bubbleButtonKey,
            onTap: () {
              final bubbleContent = BubbleLabelContent(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                        child: const Text('button'),
                      ),
                    ),
                  ),
                ),
                bubbleColor: Colors.greenAccent,
                backgroundOverlayLayerOpacity: widget.useOverlay ? 0.25 : 0.0,
                shouldActivateOnLongPressOnAllPlatforms: true,
                dismissOnBackgroundTap: true,
                shouldIgnorePointer: widget.shouldIgnorePointer,
              );

              BubbleLabel.show(
                bubbleContent: bubbleContent,
                animate: widget.animate,
                anchorKey: bubbleButtonKey,
              );
            },
            child: Container(
              key: const Key('tap-container-button'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    'Tap widget',
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
          ),

          /// A simple button that shows a bubble at a custom position when tapped.
          ElevatedButton(
            key: positionOverrideButtonKey,
            onPressed: () {
              BubbleLabel.show(
                bubbleContent: BubbleLabelContent(
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('Position override bubble at (400, 150)'),
                  ),
                  bubbleColor: Colors.tealAccent,
                  positionOverride: const Offset(400, 150),
                  backgroundOverlayLayerOpacity: widget.useOverlay ? 0.35 : 0.0,
                  dismissOnBackgroundTap: true,
                ),
                animate: widget.animate,
                context: context,
              );
            },
            child: const Text(
              'Bubble\nOffset(400, 150)',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
