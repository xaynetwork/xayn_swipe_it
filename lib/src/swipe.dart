import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:swipe/src/swipe_controller.dart';
import 'package:swipe/src/swipe_option_container.dart';
import 'package:swipe/src/swipe_options_row.dart';

typedef OnController<Option> = void Function(SwipeController<Option>);
typedef OnFling<Option> = Option? Function(Iterable<Option>);
typedef OnOptionTap<Option> = void Function(Option);
typedef OptionBuilder<Option> = SwipeOptionContainer<Option> Function(
    BuildContext, Option, int, bool);

const Offset _kSomewhatLeft = Offset(-1.0, .0);
const Offset _kSomewhatRight = Offset(1.0, .0);

class Swipe<Option> extends StatefulWidget {
  /// The [child] contained by the swipe.
  final Widget child;
  final Set<Option> selectedOptions;
  final OptionBuilder<Option> optionBuilder;
  final Iterable<Option> optionsLeft, optionsRight;
  final OnOptionTap<Option>? onOptionTap;
  final WidgetBuilder? swipeAreaBuilder;
  final Rect gestureArea;
  final Duration closeAnimationDuration;
  final Duration stayOpenedDuration;
  final Duration waitBeforeClosingDuration;
  final Duration expandSingleOptionDuration;
  final Curve closeAnimationCurve;
  final BorderRadiusGeometry? borderRadius;

  /// The clip behavior.
  ///
  /// Defaults to [Clip.antiAlias].
  final Clip clipBehavior;
  final double minDragDistanceToOpen;
  final double opensToPosition;
  final OnController<Option>? onController;
  final OnFling<Option>? onFling;
  final bool autoToggleSelection;

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
    this.waitBeforeClosingDuration = const Duration(milliseconds: 1200),
    this.expandSingleOptionDuration = const Duration(milliseconds: 120),
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.minDragDistanceToOpen = .3,
    this.opensToPosition = .8,
    this.onController,
    this.onFling,
    this.autoToggleSelection = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SwipeState<Option>();
}

class _SwipeState<Option> extends State<Swipe<Option>>
    with SingleTickerProviderStateMixin {
  final SwipeController<Option> controller = SwipeController<Option>();
  late final AnimationController animationController;
  List<SwipeOptionContainer<Option>> builtOptionsLeft = const [],
      builtOptionsRight = const [];
  bool _isOpened = false;
  Offset _offset = const Offset(.0, .0);
  Timer? _stayOpenedTimer;
  Option? _tappedLeft, _tappedRight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: animationController,
        builder: (context, gestureDetector) {
          final opacity = math.sqrt(animationController.value);
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
    if (widget.optionsLeft != oldWidget.optionsLeft ||
        widget.optionsRight != oldWidget.optionsRight) {
      _rebuildOptions();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.dispose();
    animationController.dispose();
    _stayOpenedTimer?.cancel();

    builtOptionsLeft = builtOptionsRight = const [];

    super.dispose();
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this);

    for (final option in widget.selectedOptions) {
      controller.updateSelection(option: option, isSelected: true);
    }

    if (widget.onController != null) {
      widget.onController!(controller);
    }

    controller.addListener(() {
      final optionToSelect = controller.optionToSelect;

      if (optionToSelect != null) {
        _openAndSelectOption(optionToSelect);
      } else {
        setState(_rebuildOptions);
      }
    });

    _rebuildOptions();

    super.initState();
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
          final isNotIdle = _isOpened || animationController.isAnimating;
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
      Iterable<Option> options) sync* {
    var index = 0;

    for (var option in options) {
      yield widget.optionBuilder(
        context,
        option,
        index++,
        controller.isSelected(option),
      );
    }
  }

  Future<void> _closeOptions([_]) async {
    if (_isOpened) {
      _stayOpenedTimer?.cancel();

      await animationController.animateTo(
        .0,
        duration: widget.closeAnimationDuration,
        curve: widget.closeAnimationCurve,
      );

      setState(() {
        _isOpened = false;
      });
    }
  }

  Future<void> _openAndSelectOption(Option option) async {
    if (widget.optionsLeft.contains(option)) {
      _offset = _kSomewhatRight;
    } else if (widget.optionsRight.contains(option)) {
      _offset = _kSomewhatLeft;
    }

    setState(() {
      _isOpened = true;
    });

    await animationController.animateTo(1.0,
        duration: const Duration(milliseconds: 350));

    await _selectOption(option);
  }

  Future<void> Function(DragEndDetails) _onDragEnd(BoxConstraints constraints,
          {Option? optionToSelect}) =>
      (DragEndDetails details) async {
        if (_isOpened) {
          return;
        }

        final isOpened =
            animationController.value >= widget.minDragDistanceToOpen;
        final velocity = details.primaryVelocity ?? .0;
        final didFling = velocity.abs() > 1000.0 &&
            _offset.dx.abs() > constraints.maxWidth / 2;
        final options =
            _offset.dx >= .0 ? widget.optionsLeft : widget.optionsRight;

        setState(() => _isOpened = isOpened);

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

        if (didFling && (optionToSelect != null || widget.onFling != null)) {
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
    await Future.delayed(widget.waitBeforeClosingDuration);
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

      _tappedLeft = widget.optionsLeft.contains(option) ? option : null;
      _tappedRight = widget.optionsRight.contains(option) ? option : null;
    });
  }
}
