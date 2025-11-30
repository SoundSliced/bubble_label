import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_label/bubble_label.dart';

void main() {
  testWidgets('show and dismiss BubbleLabel', (WidgetTester tester) async {
    await tester.pumpWidget(BubbleLabelController(
      child: const MaterialApp(
        home: Scaffold(body: Center(child: Text('content'))),
      ),
    ));

    // Initially nothing should be shown
    expect(BubbleLabel.isActive, isFalse);

    // Show the bubble label with a fake anchor position
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Test bubble'),
      ),
      animate: false,
    );

    // Wait for the next microtask to have controller updated
    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isTrue);
    expect(BubbleLabel.controller.state!.child, isNotNull);
    // the bubble content should be visible in the widget tree
    expect(find.text('Test bubble'), findsOneWidget);
    // the size should match the provided values
    // Bubble size adapts to child; we no longer assert explicit width/height

    // Dismiss the bubble and await completion; with animate=false this should
    // complete immediately (no timer) so awaiting won't hang the test.
    await BubbleLabel.dismiss(animate: false);
    // pumpAndSettle to allow any animations/timers to finish so timers don't
    // remain pending at the end of the test
    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isFalse);
  });

  testWidgets('dismiss via UI button', (WidgetTester tester) async {
    // Build a widget with a show and dismiss button like the example
    await tester.pumpWidget(BubbleLabelController(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  return ElevatedButton(
                    key: const Key('ui-show'),
                    onPressed: () {
                      final renderBox = context.findRenderObject() as RenderBox;
                      // Obtain renderBox for automatic anchor derivation

                      BubbleLabel.show(
                        bubbleContent: BubbleLabelContent(
                          child: const Text('UI show'),
                          childWidgetRenderBox: renderBox,
                          // bubble size adapts to its child
                        ),
                      );
                    },
                    child: const Text('Show'),
                  );
                }),
                const SizedBox(height: 8),
                ElevatedButton(
                  key: const Key('ui-dismiss'),
                  onPressed: () => BubbleLabel.dismiss(animate: false),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    // Tap show
    await tester.tap(find.byKey(const Key('ui-show')));
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isTrue);
    expect(find.text('UI show'), findsOneWidget);

    // Tap dismiss
    await tester.tap(find.byKey(const Key('ui-dismiss')));
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isFalse);
  });

  testWidgets(
      'bubble sets overlay opacity and bubble color in controller state',
      (WidgetTester tester) async {
    await tester.pumpWidget(BubbleLabelController(
      child: const MaterialApp(
        home: Scaffold(body: Center(child: Text('content'))),
      ),
    ));

    expect(BubbleLabel.isActive, isFalse);

    // Show the bubble label with custom color and overlay opacity
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Opacity test'),
        // bubble size adapts to its child
        bubbleColor: Colors.deepPurpleAccent,
        backgroundOverlayLayerOpacity: 0.41,
      ),
      animate: false,
    );

    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isTrue);
    expect(BubbleLabel.controller.state!.bubbleColor,
        equals(Colors.deepPurpleAccent));
    expect(BubbleLabel.controller.state!.backgroundOverlayLayerOpacity,
        equals(0.41));

    await BubbleLabel.dismiss(animate: false);
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isFalse);
  });

  testWidgets('bubble ignorePointer reflects controller setting',
      (WidgetTester tester) async {
    // With shouldIgnorePointer=true (default)
    await tester.pumpWidget(BubbleLabelController(
      child: const MaterialApp(
        home: Scaffold(body: Center(child: Text('content'))),
      ),
    ));

    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Ignoring true'),
        // bubble size adapts to its child
      ),
      animate: false,
    );
    await tester.pumpAndSettle();

    final ignoreBackground = tester.widget<IgnorePointer>(
        find.byKey(const Key('bubble_label_background_ignore')));
    expect(ignoreBackground, isNotNull);
    // background overlay defaults to ignoring pointer events
    expect(ignoreBackground.ignoring, isTrue);

    final ignoreBubble = tester
        .widget<IgnorePointer>(find.byKey(const Key('bubble_label_ignore')));
    expect(ignoreBubble.ignoring, isTrue);

    // Now verify that when we use a BubbleLabelController with shouldIgnorePointer=false
    await tester.pumpWidget(BubbleLabelController(
      shouldIgnorePointer: false,
      child: const MaterialApp(
        home: Scaffold(body: Center(child: Text('content'))),
      ),
    ));

    // show again
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Ignoring false'),
        // bubble size adapts to its child
      ),
      animate: false,
    );
    await tester.pumpAndSettle();

    final ignoreBubble2 = tester
        .widget<IgnorePointer>(find.byKey(const Key('bubble_label_ignore')));
    expect(ignoreBubble2.ignoring, isFalse);
  });

  testWidgets('overlay tap dismissal frees pointer events',
      (WidgetTester tester) async {
    int counter = 0;
    await tester.pumpWidget(BubbleLabelController(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  key: const Key('increment'),
                  onPressed: () => counter++,
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        ),
      ),
    ));

    // Show bubble with dismissOnBackgroundTap true
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Tap outside to dismiss'),
        // No renderBox available in this minimal test; rely on defaults
        dismissOnBackgroundTap: true,
      ),
      animate: false,
    );
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isTrue);

    // Tap the overlay gesture detector
    await tester.tap(find.byKey(const Key('bubble_label_background_gesture')));
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isFalse);

    // Tap underlying button; should increment now (pointer events pass through)
    await tester.tap(find.byKey(const Key('increment')));
    expect(counter, equals(1));
  });

  testWidgets('long press and animation timing behavior',
      (WidgetTester tester) async {
    await tester.pumpWidget(BubbleLabelController(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: GestureDetector(
              key: const Key('longpress-test'),
              onLongPress: () {
                BubbleLabel.show(
                  bubbleContent: BubbleLabelContent(
                    child: const Text('Long pressed!'),
                    // bubble size adapts to its child
                    backgroundOverlayLayerOpacity: 0.21,
                  ),
                );
              },
              child: const Text('Long press me'),
            ),
          ),
        ),
      ),
    ));

    // simulate long press
    await tester.longPress(find.byKey(const Key('longpress-test')));
    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isTrue);
    expect(find.text('Long pressed!'), findsOneWidget);

    // Test animation timing: dismiss with animate=true should keep the bubble
    // active until the 300ms duration has passed
    BubbleLabel.dismiss(animate: true); // do not await on purpose
    // After 100ms the bubble should still be active
    await tester.pump(const Duration(milliseconds: 100));
    expect(BubbleLabel.isActive, isTrue);

    // Advance time beyond the animation delay
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isFalse);
  });
}
