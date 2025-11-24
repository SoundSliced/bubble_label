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
        childWidgetPosition: const Offset(10, 10),
        childWidgetSize: const Size(50, 50),
        labelWidth: 100,
        labelHeight: 40,
      ),
      animate: false,
    );

    // Wait for the next microtask to have controller updated
    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isTrue);
    expect(BubbleLabel.controller.state!.child, isNotNull);

    // Dismiss the bubble and await completion; with animate=false this should
    // complete immediately (no timer) so awaiting won't hang the test.
    await BubbleLabel.dismiss(animate: false);
    // pumpAndSettle to allow any animations/timers to finish so timers don't
    // remain pending at the end of the test
    await tester.pumpAndSettle();

    expect(BubbleLabel.isActive, isFalse);
  });
}
