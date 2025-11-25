//import 'package:overlay_support/overlay_support.dart';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sizer/sizer.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';

/// A widget that hosts the bubble label overlay and provides the
/// layout and animations for displaying the bubble on top of the app
/// content.
///
/// Insert `BubbleLabelController` near the root of your widget tree
/// (for example inside `MaterialApp`) and the `BubbleLabel` API
/// will use it to render an overlay containing the bubble.
class BubbleLabelController extends StatelessWidget {
  /// The content over which the bubble will be displayed. This widget
  /// typically represents the main page of your application where
  /// interactive child widgets live.
  final Widget child;

  /// Controls whether the bubble overlay should ignore pointer events.
  ///
  /// When `true` (the default) the bubble overlay will not intercept
  /// touch or pointer events, so underlying widgets remain interactive.
  final bool shouldIgnorePointer;

  /// Creates a [BubbleLabelController].
  ///
  /// The [child] parameter must not be null and represents the content
  /// over which the bubble overlay will be rendered.
  const BubbleLabelController({
    super.key,

    /// Whether the bubble overlay should ignore pointer events.
    ///
    /// Defaults to `true`.
    this.shouldIgnorePointer = true,

    /// The widget over which the bubble is displayed.
    ///
    /// Typically the app's page content is passed as `child`.
    required this.child,
  });

  /// Returns the animation effects to apply when the bubble appears
  /// and disappears.
  ///
  /// This is used internally by the controller to animate the bubble.
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
                        key: const Key('bubble_label_background_ignore'),
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
                          key: const Key('bubble_label_ignore'),
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
  /// Defines the content and appearance of a bubble shown by
  /// `BubbleLabel.show()`.
  ///
  /// Create a `BubbleLabelContent` to specify the widget to show inside
  /// the bubble as well as color, size, padding, and how it should
  /// behave when activated.
  /// The background color to use for the bubble itself. If null, a
  /// default color will be used by `_BubbleWidget`.
  final Color? bubbleColor;

  /// Width of the bubble in logical pixels.
  final double labelWidth;

  /// Height of the bubble in logical pixels.
  final double labelHeight;

  /// Vertical padding between the child widget and the bubble (floating
  /// offset in logical pixels).
  final double floatingVerticalPadding;

  /// The widget to display inside the bubble. When null the bubble
  /// will contain an empty `Container`.
  final Widget? child;

  /// The opacity of the background overlay layer that will darken the
  /// content behind the bubble.
  final double? backgroundOverlayLayerOpacity;

  /// When true, the bubble will be activated on long press on all
  /// platforms (not just mobile).
  final bool shouldActivateOnLongPressOnAllPlatforms;

  /// The global position (screen coordinates) of the widget that the
  /// bubble is associated with. This is used to position the bubble.
  final Offset childWidgetPosition;

  /// The size of the widget that the bubble is associated with. This
  /// is used for precise positioning and to calculate the bubble
  /// position.
  final Size childWidgetSize;

  /// Creates a `BubbleLabelContent`.
  ///
  /// The `bubbleColor`, `labelWidth`, and `labelHeight` parameters
  /// can be used to customize the appearance of the bubble.
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

  /// Returns a copy of this `BubbleLabelContent` with the given fields
  /// replaced by new values. Any parameter that is `null` will preserve
  /// the original value from the current instance.
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

/// A simple controller API used to show and dismiss a `BubbleLabel`
/// overlay from anywhere in the application.
///
/// Use `BubbleLabel.show` to display a bubble and `BubbleLabel.dismiss`
/// to remove it. The `controller` getter exposes the current
/// `BubbleLabelContent` state so you can read or update the content
/// directly when needed.
class BubbleLabel {
  /// Default constructor for `BubbleLabel`.
  BubbleLabel();

  //-------------------------------------------------------------//w

  /// The injected state that holds the current [BubbleLabelContent].
  ///
  /// This can be used to read the active bubble content, or to update
  /// it without calling `show` again.
  static Injected<BubbleLabelContent?> get controller =>
      _bubbleLabelContentController;

  static Injected<bool?> get _animationController =>
      _bubbleLabelIsActiveAnimationController;
  //-------------------------------------------------------------//

  /// Returns `true` when a bubble is currently active and visible.
  static bool get isActive => controller.state != null;

  //-------------------------------------------------------------//

  /// Show a bubble overlay with the provided [bubbleContent].
  ///
  /// If `animate` is true (default) the opening animation will be
  /// played. If another bubble is active, it is dismissed first and
  /// then the new one is shown.
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

  /// Dismiss the currently active bubble.
  ///
  /// If `animate` is true (default) the closing animation will be
  /// played. If `animate` is false the bubble is removed immediately
  /// (useful for testing or when you need an immediate dismissal).
  static Future<void> dismiss({bool animate = true}) async {
    if (animate) {
      // trigger the 'dismiss' animation and refresh after it completes
      BubbleLabel._animationController.state = false;
      await Future.delayed(0.3.sec);
      BubbleLabel.controller.refresh();
    } else {
      // no animation -> refresh immediately so callers (including tests) don't have
      // to await a delayed future or pump the test clock
      BubbleLabel._animationController.state = null;
      BubbleLabel.controller.refresh();
    }
  }

  //-------------------------------------------------------------//
}
