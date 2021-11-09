import 'package:flutter/material.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';
import 'package:xayn_swipe_it_example/models/option.dart';

SwipeOptionContainer<Option> optionWidget(
  Option option,
  bool isSelected,
  bool isDisabled,
) {
  return SwipeOptionContainer(
    option: option,
    isDisabled: isDisabled,
    color:
        isSelected ? Color.lerp(option.color, Colors.teal, 0.5)! : option.color,
    child: Center(
      child: Icon(option.icon),
    ),
  );
}
