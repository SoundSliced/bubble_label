import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_label/bubble_label.dart';

void main() {
  testWidgets('show and dismiss BubbleLabel', (WidgetTester tester) async {
    final anchorKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              key: anchorKey,
              child: const Text('content'),
            ),
          ),
        ),
      ),
    );

    // Initially nothing should be shown
    expect(BubbleLabel.isActive, isFalse);

    // Show the bubble label with a fake anchor position
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Test bubble'),
      ),
      animate: false,
      anchorKey: anchorKey,
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

  testWidgets(
      'show asserts when both anchorKey and positionOverride are provided',
      (WidgetTester tester) async {
    final anchorKey = GlobalKey();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('content'))),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      () async => BubbleLabel.show(
        bubbleContent: BubbleLabelContent(
          child: const Text('Both provided'),
          positionOverride: const Offset(0, 0),
        ),
        anchorKey: anchorKey,
        animate: false,
      ),
      throwsAssertionError,
    );
  });

  testWidgets('dismiss via UI button', (WidgetTester tester) async {
    final showButtonKey = GlobalKey();
    // Build a widget with a show and dismiss button like the example
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  key: showButtonKey,
                  onPressed: () {
                    BubbleLabel.show(
                      bubbleContent: BubbleLabelContent(
                        child: const Text('UI show'),
                        // bubble size adapts to its child
                      ),
                      anchorKey: showButtonKey,
                    );
                  },
                  child: const Text('Show'),
                ),
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
    );

    // Tap show
    await tester.tap(find.byKey(showButtonKey));
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
    final anchorKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              key: anchorKey,
              child: const Text('content'),
            ),
          ),
        ),
      ),
    );

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
      anchorKey: anchorKey,
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

  testWidgets('bubble ignorePointer reflects default behavior',
      (WidgetTester tester) async {
    final anchorKey = GlobalKey();
    // Bubble ignores pointer events by default
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              key: anchorKey,
              child: const Text('content'),
            ),
          ),
        ),
      ),
    );

    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Ignoring true'),
        // bubble size adapts to its child
      ),
      animate: false,
      anchorKey: anchorKey,
    );
    await tester.pumpAndSettle();

    final ignoreBackground = tester.widget<IgnorePointer>(
        find.byKey(const Key('bubble_label_background_ignore')));
    expect(ignoreBackground, isNotNull);
    // background overlay defaults to ignoring pointer events
    expect(ignoreBackground.ignoring, isTrue);

    // Default shouldIgnorePointer is true, so AbsorbPointer should exist
    final absorbBubble = tester
        .widget<AbsorbPointer>(find.byKey(const Key('bubble_label_absorb')));
    expect(absorbBubble.absorbing, isTrue);

    // Properly dismiss to avoid pending timer issues
    await BubbleLabel.dismiss(animate: false);
    await tester.pumpAndSettle();
  });

  testWidgets('overlay tap dismissal frees pointer events',
      (WidgetTester tester) async {
    int counter = 0;
    final anchorKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(key: anchorKey, width: 1, height: 1),
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
    );

    // Show bubble with dismissOnBackgroundTap true
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Tap outside to dismiss'),
        dismissOnBackgroundTap: true,
      ),
      animate: false,
      anchorKey: anchorKey,
    );
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isTrue);

    // Tap somewhere outside the bubble's TapRegion to trigger dismissal.
    // Tapping at the screen edge should be outside the bubble.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(BubbleLabel.isActive, isFalse);

    // Tap underlying button; should increment now (pointer events pass through)
    await tester.tap(find.byKey(const Key('increment')));
    expect(counter, equals(1));
  });

  testWidgets('long press and animation timing behavior',
      (WidgetTester tester) async {
    final longPressAnchorKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GestureDetector(
              key: longPressAnchorKey,
              onLongPress: () {
                BubbleLabel.show(
                  bubbleContent: BubbleLabelContent(
                    child: const Text('Long pressed!'),
                    // bubble size adapts to its child
                    backgroundOverlayLayerOpacity: 0.21,
                  ),
                  anchorKey: longPressAnchorKey,
                );
              },
              child: const Text('Long press me'),
            ),
          ),
        ),
      ),
    );

    // simulate long press
    await tester.longPress(find.byKey(longPressAnchorKey));
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

  testWidgets('updateContent updates bubble properties while active',
      (WidgetTester tester) async {
    final anchorKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              key: anchorKey,
              child: const Text('content'),
            ),
          ),
        ),
      ),
    );

    // Show bubble with shouldIgnorePointer true
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Update test'),
        shouldIgnorePointer: true,
      ),
      animate: false,
      anchorKey: anchorKey,
    );
    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isTrue);
    expect(BubbleLabel.controller.state!.shouldIgnorePointer, isTrue);

    // Update to shouldIgnorePointer false
    final updated = BubbleLabel.updateContent(shouldIgnorePointer: false);
    await tester.pumpAndSettle();

    expect(updated, isTrue);
    expect(BubbleLabel.controller.state!.shouldIgnorePointer, isFalse);

    await BubbleLabel.dismiss(animate: false);
    await tester.pumpAndSettle();
  });

  testWidgets('updateContent returns false when bubble is not active',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('content'))),
      ),
    );

    expect(BubbleLabel.isActive, isFalse);

    // This should return false since no bubble is active
    final updated = BubbleLabel.updateContent(shouldIgnorePointer: false);

    expect(updated, isFalse);
    expect(BubbleLabel.isActive, isFalse);
  });

  testWidgets('tapRegionGroupId is accessible', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('content'))),
      ),
    );

    // tapRegionGroupId should be a consistent non-null value
    final groupId = BubbleLabel.tapRegionGroupId;
    expect(groupId, isNotNull);
    expect(groupId, equals(BubbleLabel.tapRegionGroupId)); // same value
  });

  testWidgets('shouldIgnorePointer controls AbsorbPointer presence',
      (WidgetTester tester) async {
    final anchorKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              key: anchorKey,
              child: const Text('content'),
            ),
          ),
        ),
      ),
    );

    // Show with shouldIgnorePointer false (no AbsorbPointer should exist)
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Pointer enabled'),
        shouldIgnorePointer: false,
      ),
      animate: false,
      anchorKey: anchorKey,
    );
    await tester.pumpAndSettle();

    // When shouldIgnorePointer is false, AbsorbPointer should not exist
    expect(find.byKey(const Key('bubble_label_absorb')), findsNothing);

    await BubbleLabel.dismiss(animate: false);
    await tester.pumpAndSettle();

    // Now show with shouldIgnorePointer true (AbsorbPointer should exist)
    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Pointer disabled'),
        shouldIgnorePointer: true,
      ),
      animate: false,
      anchorKey: anchorKey,
    );
    await tester.pumpAndSettle();

    // When shouldIgnorePointer is true, AbsorbPointer should exist
    final absorbBubble = tester
        .widget<AbsorbPointer>(find.byKey(const Key('bubble_label_absorb')));
    expect(absorbBubble.absorbing, isTrue);

    await BubbleLabel.dismiss(animate: false);
    await tester.pumpAndSettle();
  });

  testWidgets('onTapInside and onTapOutside callbacks are stored in content',
      (WidgetTester tester) async {
    final anchorKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Container(
              key: anchorKey,
              child: const Text('content'),
            ),
          ),
        ),
      ),
    );

    BubbleLabel.show(
      bubbleContent: BubbleLabelContent(
        child: const Text('Callback test'),
        onTapInside: (details) {},
        onTapOutside: (details) {},
      ),
      animate: false,
      anchorKey: anchorKey,
    );
    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isTrue);
    expect(BubbleLabel.controller.state!.onTapInside, isNotNull);
    expect(BubbleLabel.controller.state!.onTapOutside, isNotNull);

    await BubbleLabel.dismiss(animate: false);
    await tester.pumpAndSettle();
  });
}
