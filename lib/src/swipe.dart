library swipe;

import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:xayn_swipe_it/src/swipe_option_container.dart';
import 'package:xayn_swipe_it/src/swipe_options_row.dart';

part 'swipe_controller.dart';

/// A handler which triggers when the user applies a `fling` gesture.
/// It expects an `Option` as return value, and present a `List` of
/// all the available options in the current direction.
/// The `Option` that is returned, will then be selected.
typedef OnFling<Option> = Option? Function(Iterable<Option>);

/// A handler which invokes whenever the user taps an `Option`
typedef OnOptionTap<Option> = void Function(Option);

/// A builder which can optionally be implemented, if you desire a custom
/// widget to display an `Option`.
typedef OptionBuilder<Option> = SwipeOptionContainer<Option>? Function(
    BuildContext, Option, int, bool);

const Offset _kSomewhatLeft = Offset(-1.0, .0);
const Offset _kSomewhatRight = Offset(1.0, .0);
const double _kMinFlingVelocity = 1000.0;
const double _kMinFlingDragDistanceFraction = .5;

/// Wraps its children and adds UI handlers to swipe them to the left and/or right.
///
/// - [child] is the content which should be the swipe target.
///
/// - [selectedOptions] can optionally be used to pre-select any `Option`
///   from either [optionsLeft] or [optionsRight].
///
/// - [optionBuilder] can be used to customize a single `Option`
///   it expects a [SwipeOptionContainer] in return.
///
/// - [optionsLeft] is an `Iterable` representing the left-side `Option`s.
///
/// - [optionsRight] is an `Iterable` representing the right-side `Option`s.
///
/// - [onOptionTap] is a handler which triggers whenever an `Option` is tapped.
///
/// - [swipeAreaBuilder] by default, no UI elements are displayed to
///   indicate that the child can indeed be swiped.
///   If you want a custom UI to overlay the child, then provide this builder.
///
/// - [gestureArea] by default, the whole of [child] is covered with a
///   [GestureDetector], if you want a custom area, then provide this parameter.
///   (for example, only allow gestures on the middle-area of the child)
///
/// - [closeAnimationDuration] the `Duration` of the closing animation.
///
/// - [stayOpenedDuration] the `Duration` of the idle stay open time.
///
/// - [waitBeforeClosingDuration] the `Duration` that this widget waits before
///   it closes any open swipe options, after the user tapped on one.
///
/// - [expandSingleOptionDuration] the `Duration` for the transition animation
///   when selecting an option. The option then transitions to overtake the
///   fully available width, masking the other non-selected options.
///
/// - [closeAnimationCurve] the `Curve` which is used for the closing animation.
///
/// - [singleOptionAnimationCurve] the `Curve` which is used for the closing animation for single option.
///
/// - [borderRadius] can be used to show an optional border on the [child].
///
/// - [clipBehavior] specifies the clipping of the [child], the default value
///   is [Clip.antiAlias].
///
/// - [minDragDistanceToOpen] a value which defines how far the user needs to
///   drag-open the swipe options:
///   - if not far enough, then on release the options close
///   - if far enough, the options animate to fully open and the options
///     are presented.
///   [minDragDistanceToOpen] expects a value between 0.0 and 1.0,
///   1.0 represents the full available width, while 0.0 is zero width.
///
///  - [opensToPosition] a value indicating to what percentage the options
///    should open to.
///    [opensToPosition] expects a value between 0.0 and 1.0,
///    1.0 represents the full available width, while 0.0 is zero width.
///
///  - [onController] presents the [SwipeController] that is attached to this
///    widget.
///
///  - [onFling] is a handler which expects an `Option` in return.
///    when the user flings, then this option will be auto-selected.
///
///  - [autoToggleSelection] when true, then the [SwipeController] will
///    notify the selection.
///
/// ```dart
/// Swipe<Option>(
///   onOptionTap: (option) => print('tapped! $option'),
///   onFling: (options) => options.first,
///   child: const ColoredBox(
///     color: Colors.red,
///       child: Padding(
///         padding: EdgeInsets.all(24.0),
///         child: Text('Swipe me!'),
///       ),
///     ),
///   ),
///   borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
///   optionsLeft: const [Option.one, Option.three, Option.two],
///   optionsRight: const [Option.three],
/// )
/// ```
class Swipe<Option> extends StatefulWidget {
  /// the content which should be the swipe target
  final Widget child;

  /// optionally used to pre-select any `Option`
  /// from either [optionsLeft] or [optionsRight].
  ///
  final Set<Option> selectedOptions;

  /// can be used to customize a single `Option`
  /// it expects a [SwipeOptionContainer] in return.
  final OptionBuilder<Option> optionBuilder;

  /// an `Iterable` representing the left-side `Option`s.
  final Iterable<Option> optionsLeft;

  /// an `Iterable` representing the right-side `Option`s.
  final Iterable<Option> optionsRight;

  /// a handler which triggers whenever an `Option` is tapped.
  final OnOptionTap<Option>? onOptionTap;

  /// by default, no UI elements are displayed to
  /// indicate that the child can indeed be swiped.
  /// If you want a custom UI to overlay the child, then provide this builder.
  final WidgetBuilder? swipeAreaBuilder;

  /// by default, the whole of [child] is covered with a
  /// [GestureDetector], if you want a custom area, then provide this parameter.
  /// (for example, only allow gestures on the middle-area of the child)
  final Rect gestureArea;

  /// the `Duration` of the closing animation.
  final Duration closeAnimationDuration;

  /// the `Duration` of the idle stay open time.
  final Duration stayOpenedDuration;

  /// the `Duration` that this widget waits before
  /// it closes any open swipe options, after the user tapped on one.
  final Duration waitBeforeClosingDuration;

  /// the `Duration` for the transition animation
  /// when selecting an option. The option then transitions to overtake the
  /// fully available width, masking the other non-selected options.
  final Duration expandSingleOptionDuration;

  /// the `Curve` which is used for the closing animation.
  final Curve closeAnimationCurve;

  /// the `Curve` which is used for the closing animation for single option.
  final Curve singleOptionAnimationCurve;

  /// can be used to show an optional border on the [child].
  final BorderRadiusGeometry? borderRadius;

  /// specifies the clipping of the [child], the default value
  /// is [Clip.antiAlias].
  final Clip clipBehavior;

  /// a value which defines how far the user needs to
  /// drag-open the swipe options:
  ///   - if not far enough, then on release the options close
  ///   - if far enough, the options animate to fully open and the options
  ///     are presented.
  /// [minDragDistanceToOpen] expects a value between 0.0 and 1.0,
  /// 1.0 represents the full available width, while 0.0 is zero width.
  final double minDragDistanceToOpen;

  /// a value indicating to what percentage the options
  /// should open to.
  /// [opensToPosition] expects a value between 0.0 and 1.0,
  /// 1.0 represents the full available width, while 0.0 is zero width.
  final double opensToPosition;

  /// provides the widget with a [SwipeController].
  final SwipeController<Option>? controller;

  /// a handler which expects an `Option` in return.
  /// when the user flings, then this option will be auto-selected.
  final OnFling<Option>? onFling;

  /// when true, then the [SwipeController] will notify the selection.
  final bool autoToggleSelection;

  /// The minimum velocity on drag end for the gesture to be treated as a fling.
  final double minFlingVelocity;

  /// The minimum fraction of the width needed to activate a fling check.
  /// For example, if .5, then you need to at least drag for half of the screen.
  final double minFlingDragDistanceFraction;

  /// The main constructor to create a new `Swipe` widget.
  const Swipe({
    Key? key,
    required this.child,
    required this.optionBuilder,
    this.optionsLeft = const [],
    this.optionsRight = const [],
    this.selectedOptions = const {},
    this.onOptionTap,
    this.swipeAreaBuilder,
    this.gestureArea = Rect.zero,
    this.closeAnimationDuration = const Duration(milliseconds: 240),
    this.stayOpenedDuration = const Duration(seconds: 5),
    this.closeAnimationCurve = Curves.easeOut,
    this.singleOptionAnimationCurve = Curves.easeOut,
    this.waitBeforeClosingDuration = const Duration(milliseconds: 1200),
    this.expandSingleOptionDuration = const Duration(milliseconds: 120),
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.minDragDistanceToOpen = .3,
    this.opensToPosition = .8,
    this.controller,
    this.onFling,
    this.autoToggleSelection = true,
    this.minFlingVelocity = _kMinFlingVelocity,
    this.minFlingDragDistanceFraction = _kMinFlingDragDistanceFraction,
  })  : assert(0 < opensToPosition && opensToPosition <= 1,
            'opensToPosition must be a fraction with value between 0 and 1.'),
        assert(0 < minDragDistanceToOpen && minDragDistanceToOpen <= 1,
            'minDragDistanceToOpen must be a fraction with value between 0 and 1.'),
        assert(minFlingVelocity >= .0, 'minFlingVelocity must be at least .0.'),
        assert(
            0 < minFlingDragDistanceFraction &&
                minFlingDragDistanceFraction <= 1,
            'minFlingDragDistanceFraction must be a fraction with value between 0 and 1.'),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _SwipeState<Option>();
}

class _SwipeState<Option> extends State<Swipe<Option>>
    with SingleTickerProviderStateMixin {
  late final SwipeController<Option> controller;
  late final AnimationController animationController;
  List<SwipeOptionContainer<Option>> builtOptionsLeft = const [],
      builtOptionsRight = const [];
  Offset _offset = const Offset(.0, .0);
  Timer? _stayOpenedTimer;
  Option? _tappedLeft, _tappedRight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: animationController,
        builder: (context, gestureDetector) {
          final openRatio =
              math.sqrt(animationController.value / widget.opensToPosition);
          final opacity = openRatio.clamp(.0, 1.0);
          final bgColor = _resolveBackgroundColor(opacity);
          final left = _offset.dx > .0
                  ? animationController.value * constraints.maxWidth
                  : null,
              right = _offset.dx < .0
                  ? animationController.value * constraints.maxWidth
                  : null;

          return Container(
            clipBehavior: widget.clipBehavior,
            decoration: BoxDecoration(borderRadius: widget.borderRadius),
            child: _buildLayers(
              left: left,
              right: right,
              constraints: constraints,
              bgColor: bgColor,
              opacity: opacity,
              gestureDetector: gestureDetector!,
            ),
          );
        },
        child: _buildGestureDetector(context, constraints),
      );
    });
  }

  @override
  void didUpdateWidget(Swipe<Option> oldWidget) {
    final equals = IterableEquality<Option>().equals;

    if (!equals(widget.optionsLeft, oldWidget.optionsLeft) ||
        !equals(widget.optionsRight, oldWidget.optionsRight)) {
      _rebuildOptions();
    }

    if (!equals(widget.selectedOptions, oldWidget.selectedOptions)) {
      _updateSelectedOptions();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    } else {
      controller.removeListener(_onController);
    }

    animationController.dispose();
    _stayOpenedTimer?.cancel();

    builtOptionsLeft = builtOptionsRight = const [];

    super.dispose();
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this);

    controller = widget.controller ?? SwipeController<Option>();
    controller.addListener(_onController);

    _updateSelectedOptions();
    _rebuildOptions();

    super.initState();
  }

  void _onController() {
    final optionToSelect = controller._optionToSelect;

    if (optionToSelect != null) {
      _openAndSelectOption(optionToSelect);
    } else {
      setState(_rebuildOptions);
    }
  }

  void _updateSelectedOptions() {
    assert(
        widget.selectedOptions.every((element) =>
            [...widget.optionsRight, ...widget.optionsLeft].contains(element)),
        'selectedOptions has an option that doesn\'t exist in optionsLeft nor optionsRight.');

    controller._clearSelectedOptions();

    for (final option in widget.selectedOptions) {
      controller.updateSelection(option: option, isSelected: true);
    }
  }

  void _rebuildOptions() {
    builtOptionsLeft =
        _buildOptions(widget.optionsLeft).toList(growable: false);
    builtOptionsRight =
        _buildOptions(widget.optionsRight).toList(growable: false);
  }

  Widget _buildGestureDetector(
      BuildContext context, BoxConstraints constraints) {
    maybeBuildChild() {
      final builder = widget.swipeAreaBuilder;

      if (builder != null) {
        return builder(context);
      }

      return null;
    }

    return Positioned(
      left: widget.gestureArea.left,
      right: widget.gestureArea.right,
      top: widget.gestureArea.top,
      bottom: widget.gestureArea.bottom,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          final isNotIdle =
              controller.isOpened || animationController.isAnimating;
          final canSwipeLeftToRight =
              widget.optionsLeft.isEmpty && details.delta.dx > .0;
          final canSwipeRightToLeft =
              widget.optionsRight.isEmpty && details.delta.dx < .0;

          if (isNotIdle || canSwipeLeftToRight || canSwipeRightToLeft) {
            return;
          }

          _offset += details.delta;

          animationController.value = (_offset.dx / constraints.maxWidth).abs();
        },
        onHorizontalDragEnd: _onDragEnd(constraints),
        child: maybeBuildChild(),
      ),
    );
  }

  Widget _buildLayers({
    required BoxConstraints constraints,
    required Widget gestureDetector,
    required Color bgColor,
    required double opacity,
    double? left,
    double? right,
  }) {
    return Stack(
      children: [
        Positioned(
          left: left,
          right: right,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: ColoredBox(
            color: bgColor,
          ),
        ),
        Positioned(
          left: 0,
          width: left ?? .0,
          height: constraints.maxHeight,
          child: Opacity(
            opacity: opacity,
            child: SwipeOptionsRow<Option>(
              children: builtOptionsLeft,
              expandSingleOptionDuration: widget.expandSingleOptionDuration,
              highlightedOption: _tappedLeft,
              onOptionTap: _selectOption,
              onAnimationEnd: _onOptionPresented,
              singleOptionAnimationCurve: widget.singleOptionAnimationCurve,
            ),
          ),
        ),
        Positioned(
          right: 0,
          width: right ?? .0,
          height: constraints.maxHeight,
          child: Opacity(
              opacity: opacity,
              child: SwipeOptionsRow<Option>(
                children: builtOptionsRight,
                expandSingleOptionDuration: widget.expandSingleOptionDuration,
                highlightedOption: _tappedRight,
                onOptionTap: _selectOption,
                onAnimationEnd: _onOptionPresented,
                singleOptionAnimationCurve: widget.singleOptionAnimationCurve,
              )),
        ),
        Positioned(
          left: left,
          right: right,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Listener(
            onPointerDown: _closeOptions,
            child: Container(
              child: widget.child,
              clipBehavior: widget.clipBehavior,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
              ),
            ),
          ),
        ),
        gestureDetector,
      ],
    );
  }

  Iterable<SwipeOptionContainer<Option>> _buildOptions(
      Iterable<Option> options) {
    var index = 0;

    return options
        .map((option) => widget.optionBuilder(
              context,
              option,
              index++,
              controller.isSelected(option),
            ))
        .where((it) => it != null)
        .cast<SwipeOptionContainer<Option>>();
  }

  Future<void> _closeOptions([PointerDownEvent? _]) async {
    if (controller.isOpened) {
      _stayOpenedTimer?.cancel();

      await animationController.animateTo(
        .0,
        duration: widget.closeAnimationDuration,
        curve: widget.closeAnimationCurve,
      );

      controller._updateIsOpened(false);
    }
  }

  Future<void> _openAndSelectOption(Option option) async {
    if (widget.optionsLeft.contains(option)) {
      _offset = _kSomewhatRight;
    } else if (widget.optionsRight.contains(option)) {
      _offset = _kSomewhatLeft;
    }

    controller._updateIsOpened(true);
    await animationController.animateTo(1.0,
        duration: const Duration(milliseconds: 350));

    await _selectOption(option);
  }

  Future<void> Function(DragEndDetails) _onDragEnd(BoxConstraints constraints,
          {Option? optionToSelect}) =>
      (DragEndDetails details) async {
        if (controller.isOpened) {
          return;
        }

        final isOpened =
            animationController.value >= widget.minDragDistanceToOpen;
        final velocity = details.primaryVelocity ?? .0;
        final didFling = velocity.abs() > widget.minFlingVelocity &&
            _offset.dx.abs() >
                constraints.maxWidth * widget.minFlingDragDistanceFraction;
        final options = _offset.dx >= .0
            ? builtOptionsLeft.map((it) => it.option)
            : builtOptionsRight.map((it) => it.option);
        final isPresentingSingleOption = isOpened && options.length == 1;

        controller._updateIsOpened(isOpened);

        final targetPosition = isOpened ? widget.opensToPosition : .0;

        if (animationController.value != targetPosition) {
          await animationController.animateTo(
            targetPosition,
            duration: widget.closeAnimationDuration,
            curve: widget.closeAnimationCurve,
          );
        }

        _offset = Offset(
            targetPosition * _offset.dx >= .0
                ? animationController.value
                : -animationController.value,
            .0);

        _stayOpenedTimer?.cancel();

        bool didSelectOption = false;

        if ((didFling || isPresentingSingleOption) &&
            (optionToSelect != null || widget.onFling != null)) {
          final selectedOption = optionToSelect ?? widget.onFling!(options);

          if (selectedOption != null) {
            await _selectOption(selectedOption);

            didSelectOption = true;
          }
        }

        if (!didSelectOption) {
          if (isOpened) {
            _stayOpenedTimer = Timer(widget.stayOpenedDuration, _closeOptions);
          }
        }
      };

  Future<void> _onOptionPresented() async {
    await Future<void>.delayed(widget.waitBeforeClosingDuration);
    await _closeOptions();

    final tappedEither = _tappedLeft ?? _tappedRight;

    if (widget.onOptionTap != null && tappedEither != null) {
      widget.onOptionTap!(tappedEither);
    }

    setState(() {
      _rebuildOptions();
      _tappedLeft = _tappedRight = null;
    });
  }

  Color _resolveBackgroundColor(double opacity) {
    final alpha = (opacity * 0xff).round();
    var color = Colors.transparent;

    if (_offset.dx > .0 && builtOptionsLeft.isNotEmpty) {
      color = builtOptionsLeft.last.color;
    } else if (_offset.dx < .0 && builtOptionsRight.isNotEmpty) {
      color = builtOptionsRight.last.color;
    }

    return Color.fromARGB(alpha, color.red, color.green, color.blue);
  }

  Future<void> _selectOption(Option option) async {
    if (widget.autoToggleSelection) {
      controller.updateSelection(
          option: option, isSelected: !controller.isSelected(option));
    }

    setState(() {
      _rebuildOptions();

      _tappedLeft = builtOptionsLeft.map((it) => it.option).contains(option)
          ? option
          : null;
      _tappedRight = builtOptionsRight.map((it) => it.option).contains(option)
          ? option
          : null;
    });
  }
}
