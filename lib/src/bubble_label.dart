import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soundsliced_dart_extensions/soundsliced_dart_extensions.dart';
import 'package:states_rebuilder_extended/states_rebuilder_extended.dart';
import 'package:xid/xid.dart';

//******************************************* */

/// Stores the anchor key for dynamic position tracking
GlobalKey? _activeAnchorKey;

/// Internal widget that renders the bubble content with animations.
class _BubbleBuildWidget extends StatefulWidget {
  final BubbleLabelContent content;
  final List<Effect<dynamic>> effects;
  final bool shouldIgnorePointer;

  const _BubbleBuildWidget({
    required this.content,
    required this.effects,
    required this.shouldIgnorePointer,
  });

  @override
  State<_BubbleBuildWidget> createState() => _BubbleBuildWidgetState();
}

class _BubbleBuildWidgetState extends State<_BubbleBuildWidget>
    with WidgetsBindingObserver {
  Offset _currentPosition = Offset.zero;
  Size _currentSize = const Size(100, 40);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updatePosition();
    // Schedule a post-frame callback to update position after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updatePosition();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Screen size/orientation changed
    _schedulePositionUpdate();
  }

  void _schedulePositionUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updatePosition();
    });
  }

  void _updatePosition() {
    final newPosition = _computeAnchorPosition();
    final newSize = _computeAnchorSize();

    if (newPosition != _currentPosition || newSize != _currentSize) {
      setState(() {
        _currentPosition = newPosition;
        _currentSize = newSize;
      });
    }
  }

  Offset _computeAnchorPosition() {
    // If position override is set, use it
    if (widget.content.positionOverride != null) {
      return widget.content.positionOverride!;
    }

    // Try to get position from the active anchor key (if provided)
    if (_activeAnchorKey != null) {
      final context = _activeAnchorKey!.currentContext;
      if (context != null) {
        final renderObject = context.findRenderObject();
        if (renderObject is RenderBox && renderObject.attached) {
          return renderObject.localToGlobal(Offset.zero);
        }
      }
    }

    // Fallback to stored render box (from context or anchorKey)
    if (widget.content._renderBox != null &&
        widget.content._renderBox!.attached) {
      return widget.content._renderBox!.localToGlobal(Offset.zero);
    }

    return widget.content.anchorPosition;
  }

  Size _computeAnchorSize() {
    // If position override is set, use default size
    if (widget.content.positionOverride != null) {
      return const Size(100, 40);
    }

    // Try to get size from the active anchor key (if provided)
    if (_activeAnchorKey != null) {
      final context = _activeAnchorKey!.currentContext;
      if (context != null) {
        final renderObject = context.findRenderObject();
        if (renderObject is RenderBox && renderObject.attached) {
          return renderObject.size;
        }
      }
    }

    // Fallback to stored render box (from context or anchorKey)
    if (widget.content._renderBox != null &&
        widget.content._renderBox!.attached) {
      return widget.content._renderBox!.size;
    }

    return widget.content.anchorSize;
  }

  @override
  void didUpdateWidget(covariant _BubbleBuildWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update position when widget updates (e.g., content changes)
    _schedulePositionUpdate();
  }

  @override
  Widget build(BuildContext context) {
    // Schedule position update for next frame to catch layout changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updatePosition();
    });

    return Positioned(
      // Vertical position: bubble bottom at (anchor top - padding).
      // Positive padding => bubble above anchor; negative => below.
      top: _currentPosition.dy - widget.content.floatingVerticalPadding,

      // Calculate initial left position
      // to center the bubble on the child widget
      left: _currentPosition.dx + _currentSize.width / 2,
      child: FractionalTranslation(
        // Center horizontally and align bottom to the top coordinate
        translation: const Offset(-0.5, -1.0),
        child: TapRegion(
          key: const Key('bubble_label_tap_region'),
          // Group ID allows external widgets to join this TapRegion group
          groupId: _bubbleLabelTapRegionGroupId,
          // Use deferToChild so child widgets can still receive taps
          behavior: HitTestBehavior.deferToChild,
          // Don't consume outside taps - just observe them
          consumeOutsideTaps: false,
          onTapOutside: (event) {
            // Call user callback if provided
            widget.content.onTapOutside?.call(
              TapDownDetails(globalPosition: event.position),
            );
            // Only dismiss if dismissOnBackgroundTap is true
            if (widget.content.dismissOnBackgroundTap) {
              BubbleLabel.dismiss();
            }
          },
          onTapInside: (event) {
            // Call user callback if provided
            widget.content.onTapInside?.call(
              TapDownDetails(globalPosition: event.position),
            );
            // Just observe - don't consume, let child widgets handle the tap
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              //the arrow tip of the bubble
              Positioned(
                bottom: -12,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Transform.scale(
                    scale: 2.0,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: widget.content.bubbleColor,
                    ),
                  ),
                ),
              ),

              // The bubble content - use AbsorbPointer when ignoring so TapRegion still detects inside/outside
              Builder(
                builder: (context) {
                  final bubbleWidget = _BubbleWidget(
                    bubbleColor: widget.content.bubbleColor,
                    content: widget.content.child ?? Container(),
                  );
                  // Use AbsorbPointer when ignoring: it still participates in hit testing
                  // (so TapRegion knows taps are "inside"), but doesn't pass events to children.
                  // When NOT ignoring, just return the widget directly so children get taps.
                  if (widget.shouldIgnorePointer) {
                    return AbsorbPointer(
                      key: const Key('bubble_label_absorb'),
                      absorbing: true,
                      child: bubbleWidget,
                    );
                  } else {
                    return bubbleWidget;
                  }
                },
              )
            ],
          ).animate(
            effects: widget.effects,
          ),
        ),
      ),
    );
  }
}

class _BubbleWidget extends StatelessWidget {
  final Color? bubbleColor;
  final Widget content;

  const _BubbleWidget({
    this.bubbleColor,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: bubbleColor ?? Colors.blue.shade300,
        ),
        child: Center(
          child: content,
        ),
      ),
    );
  }
}

/// The background overlay widget that appears behind the bubble.
class _BackgroundOverlayWidget extends StatefulWidget {
  final BubbleLabelContent? content;
  final bool? isActive;

  const _BackgroundOverlayWidget({
    required this.content,
    required this.isActive,
  });

  @override
  State<_BackgroundOverlayWidget> createState() =>
      _BackgroundOverlayWidgetState();
}

class _BackgroundOverlayWidgetState extends State<_BackgroundOverlayWidget> {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      key: const Key('bubble_label_background_ignore'),
      child: Container(
        color: Colors.black.withValues(
          alpha: widget.content?.backgroundOverlayLayerOpacity ?? 0,
        ),
      ).animate(
        effects: widget.isActive == null
            ? []
            : widget.isActive == true
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

final _bubbleLabelBackgroundOverlayEntryController = RM.inject<OverlayEntry?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

final _bubbleLabelBubbleEntryController = RM.inject<OverlayEntry?>(
  () => null,
  autoDisposeWhenNotUsed: true,
);

/// Timer for the dismiss animation - can be cancelled if a new dismiss is called
Timer? _dismissAnimationTimer;

/// The group ID object used by the bubble's TapRegion.
/// External widgets can wrap themselves with TapRegion using this groupId
/// to be considered "inside" the bubble (preventing dismissOnBackgroundTap).
final Object _bubbleLabelTapRegionGroupId = Object();
//******************************************* */

/// Defines the content and appearance of a bubble shown by
/// `BubbleLabel.show()`.
class BubbleLabelContent {
  ///
  /// Create a `BubbleLabelContent` to specify the widget to show inside
  /// the bubble as well as color, size, padding, and how it should
  /// behave when activated.
  ///

  final String? id;

  /// The background color to use for the bubble itself. If null, a
  /// default color will be used by `_BubbleWidget`.
  final Color? bubbleColor;

  // Removed explicit label width and height; bubble adapts to child size.

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

  // Removed explicit childWidgetPosition and childWidgetSize.
  // Position and size are now derived from [childWidgetRenderBox] or
  // [positionOverride]. Use the computed getters below.

  /// Optional render box of the widget the bubble is anchored to. This is
  /// managed internally; callers provide an [anchorKey] when calling
  /// `BubbleLabel.show` so they no longer need to supply the render box
  /// themselves.
  final RenderBox? _childWidgetRenderBox;

  /// Optional explicit position override. When provided, this value will be
  /// used as the anchor position and any [childWidgetRenderBox] will be
  /// ignored for positioning.
  final Offset? positionOverride;

  /// if true, tapping on the background overlay will dismiss the bubble.
  final bool dismissOnBackgroundTap;

  /// When true (default), the bubble ignores pointer events, allowing
  /// taps to pass through to widgets underneath. When false, the bubble
  /// content can receive pointer events (e.g., buttons inside the bubble).
  final bool shouldIgnorePointer;

  /// Optional callback invoked when a tap is detected inside the bubble.
  /// Useful for visual feedback or analytics.
  final void Function(TapDownDetails event)? onTapInside;

  /// Optional callback invoked when a tap is detected outside the bubble.
  /// Called before `dismissOnBackgroundTap` logic is applied.
  final void Function(TapDownDetails event)? onTapOutside;

  /// Creates a `BubbleLabelContent`.
  ///
  /// The `bubbleColor`, `labelWidth`, and `labelHeight` parameters
  /// can be used to customize the appearance of the bubble.
  BubbleLabelContent._internal({
    String? id,
    this.bubbleColor,
    this.child,
    this.backgroundOverlayLayerOpacity,
    // label size is derived from child
    double? verticalPadding,
    this.shouldActivateOnLongPressOnAllPlatforms = false,
    RenderBox? childWidgetRenderBox,
    this.positionOverride,
    this.dismissOnBackgroundTap = false,
    this.shouldIgnorePointer = true,
    this.onTapInside,
    this.onTapOutside,
  })  : id = id ?? Xid().toString(),
        // Default: slightly above anchor (5 px)
        floatingVerticalPadding = verticalPadding ?? 5.0,
        _childWidgetRenderBox = childWidgetRenderBox;

  /// Creates a `BubbleLabelContent`.
  BubbleLabelContent({
    String? id,
    this.bubbleColor,
    this.child,
    this.backgroundOverlayLayerOpacity,
    // label size is derived from child
    double? verticalPadding,
    this.shouldActivateOnLongPressOnAllPlatforms = false,
    this.positionOverride,
    this.dismissOnBackgroundTap = false,
    this.shouldIgnorePointer = true,
    this.onTapInside,
    this.onTapOutside,
  })  : id = id ?? Xid().toString(),
        floatingVerticalPadding = verticalPadding ?? 5.0,
        _childWidgetRenderBox = null;

  // Computed anchor position based on override or render box
  RenderBox? get _renderBox => _childWidgetRenderBox;

  /// computed anchor position based on override or render box
  Offset get anchorPosition =>
      positionOverride ??
      (_renderBox != null
          ? _renderBox!.localToGlobal(Offset.zero)
          : const Offset(0, 0));

  /// Computed anchor size
  Size get anchorSize => positionOverride != null
      ? const Size(100, 40)
      : (_renderBox?.size ?? const Size(100, 40));

  /// Returns a copy of this `BubbleLabelContent` with the given fields
  /// replaced by new values. Any parameter that is `null` will preserve
  /// the original value from the current instance.
  BubbleLabelContent copyWith({
    Color? bubbleColor,
    double? floatingVerticalPadding,
    Widget? child,
    double? backgroundOverlayLayerOpacity,
    bool? shouldActiveOnLongPressOnAllPlatforms,
    String? id,
    Offset? positionOverride,
    bool? shouldIgnorePointer,
    void Function(TapDownDetails event)? onTapInside,
    void Function(TapDownDetails event)? onTapOutside,
  }) {
    return BubbleLabelContent._internal(
      id: id ?? this.id,
      bubbleColor: bubbleColor ?? this.bubbleColor,
      verticalPadding: floatingVerticalPadding ?? this.floatingVerticalPadding,
      child: child ?? this.child,
      backgroundOverlayLayerOpacity:
          backgroundOverlayLayerOpacity ?? this.backgroundOverlayLayerOpacity,
      shouldActivateOnLongPressOnAllPlatforms:
          shouldActiveOnLongPressOnAllPlatforms ??
              shouldActivateOnLongPressOnAllPlatforms,
      childWidgetRenderBox: _childWidgetRenderBox,
      positionOverride: positionOverride ?? this.positionOverride,
      dismissOnBackgroundTap: dismissOnBackgroundTap,
      shouldIgnorePointer: shouldIgnorePointer ?? this.shouldIgnorePointer,
      onTapInside: onTapInside ?? this.onTapInside,
      onTapOutside: onTapOutside ?? this.onTapOutside,
    );
  }

  BubbleLabelContent _withRenderBox(RenderBox? renderBox) {
    return BubbleLabelContent._internal(
      id: id,
      bubbleColor: bubbleColor,
      child: child,
      backgroundOverlayLayerOpacity: backgroundOverlayLayerOpacity,
      verticalPadding: floatingVerticalPadding,
      shouldActivateOnLongPressOnAllPlatforms:
          shouldActivateOnLongPressOnAllPlatforms,
      childWidgetRenderBox: renderBox,
      positionOverride: positionOverride,
      dismissOnBackgroundTap: dismissOnBackgroundTap,
      shouldIgnorePointer: shouldIgnorePointer,
      onTapInside: onTapInside,
      onTapOutside: onTapOutside,
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
///
/// No wrapper widget is required! The app just needs to use MaterialApp,
/// CupertinoApp, or have an Overlay widget in the widget tree.
class BubbleLabel {
  /// Default constructor for `BubbleLabel`.
  BubbleLabel();

  //-------------------------------------------------------------//

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

  /// Returns `true` when a bubble is currently active and visible by id.
  static bool isActiveById(String? id) =>
      id == null ? false : controller.state?.id == id;

  /// The group ID object used by the bubble's TapRegion.
  ///
  /// External widgets can wrap themselves with a `TapRegion` using this
  /// `groupId` to be considered "inside" the bubble. This prevents
  /// `dismissOnBackgroundTap` from triggering when tapping those widgets.
  ///
  /// Example:
  /// ```dart
  /// TapRegion(
  ///   groupId: BubbleLabel.tapRegionGroupId,
  ///   child: MyWidget(),
  /// )
  /// ```
  static Object get tapRegionGroupId => _bubbleLabelTapRegionGroupId;

  //-------------------------------------------------------------//

  /// Returns the animation effects to apply when the bubble appears
  /// and disappears.
  ///
  /// This is used internally to animate the bubble.
  static List<Effect<dynamic>> _getEffects() {
    List<Effect<dynamic>> effects = [];

    if (_bubbleLabelIsActiveAnimationController.state != null) {
      if (_bubbleLabelIsActiveAnimationController.state!) {
        effects = [
          FadeEffect(
            begin: 0,
            end: 1,
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

  //-------------------------------------------------------------//

  /// Show a bubble overlay with the provided [bubbleContent].
  ///
  /// If `animate` is true (default) the opening animation will be
  /// played. If another bubble is active, it is dismissed first and
  /// then the new one is shown.
  ///
  /// `context` is required and serves two purposes:
  /// 1. Finding the Overlay widget in the widget tree
  /// 2. As the anchor widget for positioning (if no `anchorKey` or
  ///    `positionOverride` is provided)
  ///
  /// `anchorKey` is optional. If provided, the bubble will be anchored to
  /// that widget. If not provided and no `positionOverride` is set, the
  /// bubble will be anchored to the widget associated with `context`.
  ///
  /// Requires: An Overlay widget in the widget tree (provided by
  /// MaterialApp, CupertinoApp, or manually added).
  static Future<void> show({
    required BuildContext context,
    required BubbleLabelContent bubbleContent,
    bool animate = true,
    GlobalKey? anchorKey,
  }) async {
    var content = bubbleContent;

    // Use the provided context for overlay lookup
    final targetContext = context;

    // Try root overlay first (works in most cases with MaterialApp/CupertinoApp)
    OverlayState? overlay = Overlay.maybeOf(targetContext, rootOverlay: true);

    // Fallback to nearest overlay
    overlay ??= Overlay.maybeOf(targetContext, rootOverlay: false);

    if (overlay == null) {
      _throwOverlayError();
      return;
    }

    //dismiss the previous bubble (just in case)
    if (BubbleLabel.isActive) {
      // When replacing an active bubble, honor the caller's animate flag.
      await BubbleLabel.dismiss(animate: animate);
    }

    if (animate) {
      BubbleLabel._animationController.state = true;
    }

    // Resolve render box: prefer anchorKey, then context, then positionOverride
    RenderBox? renderBox;
    if (anchorKey != null) {
      renderBox = _resolveAnchorRenderBox(anchorKey);
    } else if (content.positionOverride == null) {
      // Use the context's render object as the anchor
      final renderObject = context.findRenderObject();
      if (renderObject is RenderBox) {
        renderBox = renderObject;
      }
    }

    if (renderBox != null && renderBox != content._renderBox) {
      content = content._withRenderBox(renderBox);
    }

    // Store the anchor key for dynamic position tracking (null if using context)
    _activeAnchorKey = anchorKey;

    //set the new bubble content
    BubbleLabel.controller.update<BubbleLabelContent?>((state) => content);

    // Insert entries using the pre-resolved overlay
    _insertOverlayEntries(content, overlay);
  }

  //-------------------------------------------------------------//

  /// Dismiss the currently active bubble.
  ///
  /// If `animate` is true (default) the closing animation will be
  /// played. If `animate` is false the bubble is removed immediately
  /// (useful for testing or when you need an immediate dismissal).
  static Future<void> dismiss({bool animate = true}) async {
    // Cancel any pending dismiss animation timer
    _dismissAnimationTimer?.cancel();
    _dismissAnimationTimer = null;

    if (animate) {
      // trigger the 'dismiss' animation
      BubbleLabel._animationController.state = false;

      // Use a Completer to allow awaiting the timer completion
      final completer = Completer<void>();

      _dismissAnimationTimer = Timer(0.3.sec, () {
        _dismissAnimationTimer = null;
        _activeAnchorKey = null; // Clear anchor key
        _removeOverlayEntries();
        BubbleLabel.controller.refresh();
        completer.complete();
      });

      return completer.future;
    } else {
      // no animation -> remove immediately
      _activeAnchorKey = null; // Clear anchor key
      _removeOverlayEntries();
      BubbleLabel._animationController.state = null;
      BubbleLabel.controller.refresh();
    }
  }

  //-------------------------------------------------------------//

  /// Updates the currently active bubble's content properties.
  ///
  /// Use this to reactively update bubble properties while it's displayed,
  /// such as changing `shouldIgnorePointer` when a toggle changes.
  ///
  /// Only updates if a bubble is currently active. Returns `true` if
  /// the update was applied, `false` if no bubble is active.
  ///
  /// Example:
  /// ```dart
  /// BubbleLabel.updateContent(shouldIgnorePointer: newValue);
  /// ```
  static bool updateContent({
    Widget? child,
    Color? bubbleColor,
    double? backgroundOverlayLayerOpacity,
    double? floatingVerticalPadding,
    bool? shouldActiveOnLongPressOnAllPlatforms,
    Offset? positionOverride,
    bool? shouldIgnorePointer,
  }) {
    if (!isActive || controller.state == null) {
      return false;
    }

    final currentContent = controller.state!;
    controller.state = currentContent.copyWith(
      child: child,
      bubbleColor: bubbleColor,
      backgroundOverlayLayerOpacity: backgroundOverlayLayerOpacity,
      floatingVerticalPadding: floatingVerticalPadding,
      shouldActiveOnLongPressOnAllPlatforms:
          shouldActiveOnLongPressOnAllPlatforms,
      positionOverride: positionOverride,
      shouldIgnorePointer: shouldIgnorePointer,
    );
    return true;
  }

  //-------------------------------------------------------------//

  static void _throwOverlayError() {
    throw FlutterError(
      'BubbleLabel could not find an Overlay widget.\n\n'
      'This typically happens when:\n'
      '  • Your app does not use MaterialApp or CupertinoApp\n'
      '  • The widget tree has complex nesting with custom overlays\n\n'
      'Solutions:\n'
      '  1. Ensure MaterialApp/CupertinoApp is at the root of your app\n'
      '  2. Pass context explicitly: BubbleLabel.show(context: context, anchorKey: key, ...)\n'
      '  3. Wrap your widget in Builder to get proper context\n\n'
      'Example:\n'
      '  BubbleLabel.show(\n'
      '    context: context,  // Pass context here\n'
      '    anchorKey: myKey,\n'
      '    bubbleContent: BubbleLabelContent(...),\n'
      '  )\n',
    );
  }

  /// Inserts the background overlay and bubble entries into the Overlay.
  static void _insertOverlayEntries(
    BubbleLabelContent content,
    OverlayState overlay,
  ) {
    // Create background overlay entry
    final backgroundEntry = OverlayEntry(
      builder: (context) => OnBuilder(
        listenToMany: [
          BubbleLabel._animationController,
          BubbleLabel.controller,
        ],
        builder: () => _BackgroundOverlayWidget(
          content: BubbleLabel.controller.state,
          isActive: BubbleLabel._animationController.state,
        ),
      ),
    );

    // Create bubble entry
    final bubbleEntry = OverlayEntry(
      builder: (context) => Stack(
        clipBehavior: Clip.none,
        children: [
          OnBuilder(
            listenToMany: [
              BubbleLabel.controller,
              BubbleLabel._animationController
            ],
            builder: () {
              //if there is no bubble content, return an empty widget
              if (BubbleLabel.controller.state == null) {
                return const SizedBox();
              }

              //return the bubble widget
              return _BubbleBuildWidget(
                content: BubbleLabel.controller.state!,
                effects: BubbleLabel._getEffects(),
                shouldIgnorePointer:
                    BubbleLabel.controller.state!.shouldIgnorePointer,
              );
            },
          ),
        ],
      ),
    );

    // Store references
    _bubbleLabelBackgroundOverlayEntryController.state = backgroundEntry;
    _bubbleLabelBubbleEntryController.state = bubbleEntry;

    // Insert into overlay
    overlay.insert(backgroundEntry);
    overlay.insert(bubbleEntry);
  }

  //-------------------------------------------------------------//

  /// Removes the overlay entries from the Overlay.
  static void _removeOverlayEntries() {
    final backgroundEntry = _bubbleLabelBackgroundOverlayEntryController.state;
    final bubbleEntry = _bubbleLabelBubbleEntryController.state;

    if (backgroundEntry != null && backgroundEntry.mounted) {
      backgroundEntry.remove();
    }

    if (bubbleEntry != null && bubbleEntry.mounted) {
      bubbleEntry.remove();
    }

    _bubbleLabelBackgroundOverlayEntryController.state = null;
    _bubbleLabelBubbleEntryController.state = null;
  }

  //-------------------------------------------------------------//

  static RenderBox? _resolveAnchorRenderBox(GlobalKey? anchorKey) {
    if (anchorKey == null) {
      return null;
    }

    final context = anchorKey.currentContext;
    if (context == null) {
      return null;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject;
    }

    return null;
  }
}
