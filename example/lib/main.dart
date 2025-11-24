import 'package:flutter/material.dart';
import 'package:bubble_label/bubble_label.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BubbleLabelController(
      child: MaterialApp(
        title: 'Bubble Label Example',
        home: Scaffold(
          appBar: AppBar(title: const Text('Bubble Label Example')),
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
