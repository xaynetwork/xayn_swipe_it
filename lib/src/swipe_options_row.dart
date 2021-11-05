import 'package:flutter/widgets.dart';
import 'package:xayn_swipe_it/src/swipe.dart';
import 'package:xayn_swipe_it/src/swipe_option_container.dart';

/// @private
/// An internal widget, which displays `Option`s in a row and is responsible
/// for handling any animations in-between its presented options.
@protected
class SwipeOptionsRow<Option> extends StatefulWidget {
  /// A list of child widgets, representing individual `Option`s.
  final List<SwipeOptionContainer<Option>> children;

  /// A handler, which triggers whenever an `Option` is tapped.
  final OnOptionTap<Option>? onOptionTap;

  /// If applicable, indicate which `Option` should be highlighted.
  final Option? highlightedOption;

  /// A callback which triggers when the internal animation ends.
  final VoidCallback? onAnimationEnd;

  /// The amount of time in which the animation plays.
  final Duration expandSingleOptionDuration;

  /// the `Curve` which is used for the closing animation.
  final Curve singleOptionAnimationCurve;

  /// Creates a new `SwipeOptionsRow`.
  const SwipeOptionsRow({
    Key? key,
    required this.children,
    required this.expandSingleOptionDuration,
    required this.singleOptionAnimationCurve,
    this.onOptionTap,
    this.highlightedOption,
    this.onAnimationEnd,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SwipeOptionsRowState<Option>();
}

class _SwipeOptionsRowState<Option> extends State<SwipeOptionsRow<Option>>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          var offset = .0;
          final children = widget.children.map((it) {
            final child = _wrapSwipeOption(
                it, offset, animationController.value, constraints);

            offset += child.width!;

            return child;
          }).toList(growable: false);

          return Stack(children: children);
        },
      );
    });
  }

  @override
  void didUpdateWidget(SwipeOptionsRow<Option> oldWidget) {
    if (widget.highlightedOption != null) {
      if (animationController.value < 1.0) {
        animationController
            .animateTo(1.0, curve: widget.singleOptionAnimationCurve)
            .whenComplete(() {
          if (widget.onAnimationEnd != null) {
            widget.onAnimationEnd!();
          }
        });
      }
    } else if (oldWidget.highlightedOption != null) {
      animationController.animateTo(.0,
          curve: widget.singleOptionAnimationCurve);
    } else {
      animationController.value = .0;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: widget.expandSingleOptionDuration)
      ..value = .0;

    super.initState();
  }

  Positioned _wrapSwipeOption(SwipeOptionContainer<Option> container,
      double offset, double factor, BoxConstraints constraints) {
    final singleOptionSize = constraints.maxWidth / widget.children.length;
    final shouldMaximize = container.option == widget.highlightedOption;
    final child = Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: container,
      height: constraints.maxHeight,
    );

    final left = offset;
    final width = shouldMaximize
        ? singleOptionSize + factor * (constraints.maxWidth - singleOptionSize)
        : singleOptionSize - factor * singleOptionSize;

    return Positioned(
      key: Key(container.option.toString()),
      left: left.floorToDouble(),
      width: width.ceilToDouble(),
      height: constraints.maxHeight,
      child: container.isDisabled
          ? child
          : Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) => widget.onOptionTap!(container.option),
              child: child,
            ),
    );
  }
}
