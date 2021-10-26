import 'package:flutter/widgets.dart';

class SwipeOptionContainer<Option> extends ColoredBox {
  final Option option;

  const SwipeOptionContainer(
      {Key? key, required this.option, required Color color, Widget? child})
      : super(key: key, child: child, color: color);
}
