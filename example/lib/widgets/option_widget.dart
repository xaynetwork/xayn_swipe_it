import 'package:flutter/material.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';
import 'package:xayn_swipe_it_example/models/option.dart';

SwipeOptionContainer<Option> optionWidget(
  Option option,
  bool isSelected, {
  Option? displayedOption,
}) {
  final _displayedOption = displayedOption ?? option;
  return SwipeOptionContainer(
    option: option,
    color: isSelected
        ? Color.lerp(_displayedOption.color, Colors.teal, 0.5)!
        : _displayedOption.color,
    child: Center(
      child: Icon(_displayedOption.icon),
    ),
  );
}
