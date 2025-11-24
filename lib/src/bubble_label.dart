//import 'package:overlay_support/overlay_support.dart';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

class BubbleLabelController extends StatelessWidget {
  final Widget child;
  final bool shouldIgnorePointer;
  const BubbleLabelController({
    super.key,
    this.shouldIgnorePointer = true,
    required this.child,
  });

  List<Effect<dynamic>> getEffects() {
    List<Effect<dynamic>> effects = [];

    if (_bubbleLabelIsActiveAnimationController.state != null) {
      if (_bubbleLabelIsActiveAnimationController.state!) {
        effects = [
          FadeEffect(
            begin: 0,
            end: 1,
            // delay: 0.1.sec,
            duration: 0.2.sec,
            curve: Curves.easeIn,
          ),
          MoveEffect(
            begin: Offset(0, 5),
            end: Offset(0, -1),
            duration: 0.2.sec,
            curve: Curves.easeIn,
          )
        ];
      } else {
        effects = [
          MoveEffect(
            begin: Offset(0, -1),
            end: Offset(0, 5),
            duration: 0.2.sec,
            curve: Curves.easeOutBack,
          ),
          FadeEffect(
            begin: 1,
            end: 0,
            delay: 0.1.sec,
            duration: 0.2.sec,
            curve: Curves.easeOutBack,
          ),
        ];
      }
    }

    return effects;
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Box(
        height: 100.h,
        width: 100.w,
        child: Material(
          type: MaterialType.transparency,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                // the page widget over which the bubble will be displayed
                child,

                // the background overlay layer
                OnBuilder(
                    listenTo: BubbleLabel._animationController,
                    builder: () {
                      return IgnorePointer(
                        child: Box(
                          height: 100.h,
                          width: 100.w,
                          color: Colors.black.withValues(
                              alpha: BubbleLabel.controller.state
                                      ?.backgroundOverlayLayerOpacity ??
                                  0),
                        ).animate(
                          // key: ValueKey(
                          //     "BubbleLabel2BackgroundAnimation + ${_bubbleLabelIsActiveAnimationController.state}"),
                          effects: _bubbleLabelIsActiveAnimationController
                                      .state ==
                                  null
                              ? []
                              : _bubbleLabelIsActiveAnimationController.state ==
                                      true
                                  ? [
                                      FadeEffect(
                                        duration: 0.3.sec,
                                        curve: Curves.easeInOut,
                                        begin: 0,
                                        end: 1,
                                      ),
                                    ]
                                  : [
                                      FadeEffect(
                                        duration: 0.1.sec,
                                        curve: Curves.easeInOut,
                                        begin: 1,
                                        end: 0,
                                      ),
                                    ],
                        ),
                      );
                    }),

                // the bubble widget
                OnBuilder(
                    listenToMany: [
                      BubbleLabel.controller,
                      BubbleLabel._animationController
                    ],
                    builder: () {
                      //if there is no bubble content, return an empty widget
                      if (BubbleLabel.controller.state == null) {
                        return SizedBox();
                      }

                      //return the bubble widget
                      return Positioned(
                        // Calculate initial top position
                        top: BubbleLabel
                                .controller.state!.childWidgetPosition.dy -
                            BubbleLabel
                                    .controller.state!.childWidgetSize.height *
                                2 -
                            BubbleLabel
                                .controller.state!.floatingVerticalPadding,

                        // Calculate initial left position
                        // to center the bubble on the child widget
                        left: BubbleLabel
                                .controller.state!.childWidgetPosition.dx -
                            BubbleLabel.controller.state!.labelWidth / 2 +
                            BubbleLabel
                                    .controller.state!.childWidgetSize.width /
                                2,
                        child: IgnorePointer(
                          ignoring: shouldIgnorePointer,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              //the arrow tip of the buble
                              Positioned(
                                left: BubbleLabel.controller.state!.labelWidth /
                                        2 -
                                    10,
                                top: BubbleLabel.controller.state!.labelHeight -
                                    9.25,
                                child: Transform.scale(
                                  scale: 1.5,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: BubbleLabel
                                        .controller.state!.bubbleColor,
                                  ),
                                ),
                              ),

                              //the buble
                              _BubbleWidget(
                                labelWidth:
                                    BubbleLabel.controller.state!.labelWidth,
                                labelHeight:
                                    BubbleLabel.controller.state!.labelHeight,
                                bubbleColor:
                                    BubbleLabel.controller.state!.bubbleColor,
                                content: BubbleLabel.controller.state!.child ??
                                    Container(),
                              )
                            ],
                          ).animate(
                            // key: ValueKey(
                            //     "labelUpDownAnimation + ${_bubbleLabelIsActiveAnimationController.state}"),
                            effects: getEffects(),
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      );
    });
  }
}

//******************************************* */

class _BubbleWidget extends StatelessWidget {
  final double labelWidth, labelHeight;
  final Color? bubbleColor;
  final Widget? content;
  const _BubbleWidget({
    required this.labelWidth,
    required this.labelHeight,
    this.bubbleColor,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: labelHeight,
      width: labelWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bubbleColor ?? Colors.blue.shade300,
      ),
      child: Center(
        child: content ?? Container(),
      ),
    );
  }
}

//******************************************* */

final _bubbleLabelContentController = RM.inject<BubbleLabelContent?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

final _bubbleLabelIsActiveAnimationController = RM.inject<bool?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);
//******************************************* */

class BubbleLabelContent {
  final Color? bubbleColor;
  final double labelWidth, labelHeight, floatingVerticalPadding;
  final Widget? child;
  final double? backgroundOverlayLayerOpacity;
  final bool shouldActivateOnLongPressOnAllPlatforms;
  final Offset childWidgetPosition;
  final Size childWidgetSize;

  BubbleLabelContent({
    this.bubbleColor,
    this.child,
    this.backgroundOverlayLayerOpacity,
    this.labelWidth = 120,
    this.labelHeight = 35,
    this.floatingVerticalPadding = 45,
    this.shouldActivateOnLongPressOnAllPlatforms = false,
    this.childWidgetPosition = const Offset(0, 0),
    this.childWidgetSize = const Size(100, 40),
  });

  BubbleLabelContent copyWith({
    Color? bubbleColor,
    double? labelWidth,
    double? labelHeight,
    double? floatingVerticalPadding,
    Widget? child,
    double? backgroundOverlayLayerOpacity,
    bool? shouldActiveOnLongPressOnAllPlatforms,
    Offset? childWidgetPosition,
    Size? childWidgetSize,
  }) {
    return BubbleLabelContent(
      bubbleColor: bubbleColor ?? this.bubbleColor,
      labelWidth: labelWidth ?? this.labelWidth,
      labelHeight: labelHeight ?? this.labelHeight,
      floatingVerticalPadding:
          floatingVerticalPadding ?? this.floatingVerticalPadding,
      child: child ?? this.child,
      backgroundOverlayLayerOpacity:
          backgroundOverlayLayerOpacity ?? this.backgroundOverlayLayerOpacity,
      shouldActivateOnLongPressOnAllPlatforms:
          shouldActiveOnLongPressOnAllPlatforms ??
              shouldActivateOnLongPressOnAllPlatforms,
      childWidgetPosition: childWidgetPosition ?? this.childWidgetPosition,
      childWidgetSize: childWidgetSize ?? this.childWidgetSize,
    );
  }
}

class BubbleLabel {
  BubbleLabel();

  //-------------------------------------------------------------//w

  static Injected<BubbleLabelContent?> get controller =>
      _bubbleLabelContentController;

  static Injected<bool?> get _animationController =>
      _bubbleLabelIsActiveAnimationController;
  //-------------------------------------------------------------//

  static bool get isActive => controller.state != null;

  //-------------------------------------------------------------//

  static Future<void> show({
    required BubbleLabelContent bubbleContent,
    bool animate = true,
  }) async {
    // log('BubbleLabel2.show() -  size: ${bubbleContent.childWidgetSize} - position: ${bubbleContent.childWidgetPosition}');
    //dismiss the previous bubble (just in case)
    if (BubbleLabel.isActive) {
      await BubbleLabel.dismiss(animate: false);
    }

    if (animate) {
      BubbleLabel._animationController.state = true;
    }
    //set the new bubble content
    BubbleLabel.controller.update((state) => bubbleContent);
  }

  //-------------------------------------------------------------//

  static Future<void> dismiss({bool animate = true}) async {
    if (animate) {
      BubbleLabel._animationController.state = false;
    } else {
      BubbleLabel._animationController.state = null;
    }
    // log('BubbleLabel2.dismiss()');
    await Future.delayed(0.3.sec, () {
      BubbleLabel.controller.refresh();
    });
  }

  //-------------------------------------------------------------//
}
