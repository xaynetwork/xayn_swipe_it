import 'package:flutter/widgets.dart';

/// This is a utility widget, it wraps a [child] widget,
/// applies a background [color] behind it, and ties this widget to
/// the [option] passed.
class SwipeOptionContainer<Option> extends ColoredBox {
  /// The `Option` which is being displayed.
  final Option option;

  /// Constructs a new [option] widget, with a background [color] and a [child].
  const SwipeOptionContainer(
      {Key? key, required this.option, required Color color, Widget? child})
      : super(key: key, child: child, color: color);
}
