import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

import 'utils.dart';

void main() {
  group('swipe controller: ', () {
    late SwipeController<Option> _controller;

    testWidgets('update selection', (WidgetTester tester) async {
      Option? _newlySelectedOption;
      late Set<Option> selectedOptions = optionsLeft.toSet();
      late Set<Option> notSelectedOptions = optionsRight.toSet();
      await standaloneWidgetSetup(
        tester,
        widget: Swipe<Option>(
          key: const Key('updateSelection'),
          onController: (controller) => _controller = controller,
          optionBuilder: (_, option, index, isSelected) {
            if (notSelectedOptions.contains(option) && isSelected) {
              _newlySelectedOption = option;
            }
            return SwipeOptionContainer<Option>(
              option: option,
              color: Colors.white,
              child: Text(option.toString()),
            );
          },
          optionsLeft: optionsLeft,
          optionsRight: optionsRight,
          selectedOptions: selectedOptions,
          child: swipeableChild,
        ),
      );

      expect(_newlySelectedOption, isNull);
      expect(_controller, isNotNull);
      expect(_controller.isSelected(selectedOptions.first), isTrue);
      expect(_controller.isSelected(notSelectedOptions.first), isFalse);

      _controller.updateSelection(
        option: notSelectedOptions.first,
        isSelected: true,
      );
      expect(_controller.isSelected(notSelectedOptions.first), isTrue);
      expect(_newlySelectedOption, isNotNull);
      expect(_newlySelectedOption, equals(notSelectedOptions.first));
    });

    testWidgets('swipe open a not selected option',
        (WidgetTester tester) async {
      await standaloneWidgetSetup(
        tester,
        widget: Swipe<Option>(
          key: const Key('swipeOpenNotSelected'),
          onController: (controller) => _controller = controller,
          optionBuilder: (_, option, index, isSelected) {
            return SwipeOptionContainer<Option>(
              option: option,
              color: Colors.white,
              child: Text(option.toString()),
            );
          },
          optionsLeft: optionsLeft,
          optionsRight: optionsRight,
          selectedOptions: {optionsRight.first},
          child: swipeableChild,
        ),
      );

      expect(_controller, isNotNull);
      expect(_controller.isOpened, isFalse);
      _controller.swipeOpen(optionsLeft.first);
      expect(_controller.isOpened, isTrue);
    });

    testWidgets('swipe open a selected option', (WidgetTester tester) async {
      await standaloneWidgetSetup(
        tester,
        widget: Swipe<Option>(
          key: const Key('swipeOpenSelected'),
          onController: (controller) => _controller = controller,
          optionBuilder: (_, option, index, isSelected) {
            return SwipeOptionContainer<Option>(
              option: option,
              color: Colors.white,
              child: Text(option.toString()),
            );
          },
          optionsLeft: optionsLeft,
          optionsRight: optionsRight,
          selectedOptions: {optionsRight.first},
          child: swipeableChild,
        ),
      );

      expect(_controller, isNotNull);
      expect(_controller.isOpened, isFalse);
      _controller.swipeOpen(optionsRight.first);
      expect(_controller.isOpened, isTrue);
    });

    testWidgets('swipe open an option in left and right',
        (WidgetTester tester) async {
      await standaloneWidgetSetup(
        tester,
        widget: Swipe<Option>(
          key: const Key('swipeOpenSelected'),
          onController: (controller) => _controller = controller,
          optionBuilder: (_, option, index, isSelected) {
            return SwipeOptionContainer<Option>(
              option: option,
              color: Colors.white,
              child: Text(option.toString()),
            );
          },
          optionsLeft: optionsLeft,
          optionsRight: optionsLeft,
          selectedOptions: {optionsLeft.first},
          child: swipeableChild,
        ),
      );

      expect(_controller, isNotNull);
      expect(_controller.isOpened, isFalse);
      _controller.swipeOpen(optionsLeft.first);
      expect(_controller.isOpened, isTrue);
    });

    testWidgets('isOpen', (WidgetTester tester) async {
      await standaloneWidgetSetup(
        tester,
        widget: Swipe<Option>(
          key: const Key('swipeOpenSelected'),
          onController: (controller) => _controller = controller,
          optionBuilder: (_, option, index, isSelected) {
            return SwipeOptionContainer<Option>(
              option: option,
              color: Colors.white,
              child: Text(option.toString()),
            );
          },
          optionsLeft: optionsLeft,
          optionsRight: optionsLeft,
          selectedOptions: {optionsLeft.first},
          child: swipeableChild,
        ),
      );
      expect(_controller.isOpened, isFalse);
      final child = swipeableChildKeyName.findByKey();
      await swipeLeft(tester, child);
      expect(_controller.isOpened, isTrue);
      await swipeRight(tester, child);
      expect(_controller.isOpened, isTrue);
    });

    testWidgets('isOpen', (WidgetTester tester) async {
      await standaloneWidgetSetup(
        tester,
        widget: Swipe<Option>(
          key: const Key('swipeOpenSelected'),
          onController: (controller) => _controller = controller,
          optionBuilder: (_, option, index, isSelected) {
            return SwipeOptionContainer<Option>(
              option: option,
              color: Colors.white,
              child: Text(option.toString()),
            );
          },
          optionsLeft: optionsLeft,
          optionsRight: optionsLeft,
          selectedOptions: {optionsLeft.first},
          child: swipeableChild,
        ),
      );
      expect(_controller.isOpened, isFalse);
      final child = swipeableChildKeyName.findByKey();
      await swipeLeft(tester, child);
      expect(_controller.isOpened, isTrue);
      await swipeRight(tester, child);
      expect(_controller.isOpened, isTrue);
    });
  });
}
