import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_swipe_it/xayn_swipe_it.dart';

import 'utils.dart';

void main() {
  late SwipeController<Option> _controller;

  setUp(() {
    _controller = SwipeController<Option>();
  });

  group('swipe widget: ', () {
    testWidgets('tapping an option', (WidgetTester tester) async {
      Option? _newlySelectedOption;
      final notSelectedOption = optionsRight.first;
      const Key notSelectedKey = Key('notSelectedKey');
      await standaloneWidgetSetup(
        tester,
        widget: Swipe<Option>(
          key: const Key('tap option'),
          controller: _controller,
          optionBuilder: (_, option, index, isSelected) {
            if (notSelectedOption == option && isSelected) {
              _newlySelectedOption = option;
            }
            return SwipeOptionContainer<Option>(
              key: notSelectedOption == option ? notSelectedKey : null,
              option: option,
              color: Colors.white,
              child: Text(option.toString()),
            );
          },
          optionsLeft: optionsLeft,
          optionsRight: optionsRight,
          child: swipeableChild,
        ),
      );

      expect(_newlySelectedOption, isNull);
      expect(_controller.isSelected(notSelectedOption), isFalse);

      await swipeLeft(tester);
      expect(_controller.isOpened, isTrue);
      final notSelected = find.byKey(notSelectedKey);
      expect(notSelected, findsOneWidget);

      await tester.ensureVisible(notSelected);
      await tester.pump();
      await tester.tap(notSelected);
      expect(_controller.isSelected(notSelectedOption), isTrue);
      expect(_newlySelectedOption, isNotNull);
      expect(_newlySelectedOption, equals(notSelectedOption));

      await swipeLeft(tester);
      expect(_controller.isOpened, isTrue);
      expect(notSelected, findsOneWidget);
      await tester.ensureVisible(notSelected);
      await tester.pump();
      await tester.tap(notSelected);
      expect(_controller.isSelected(notSelectedOption), isFalse);
    });

    testWidgets(
      'fling',
      (WidgetTester tester) async {
        Option? flingCondition(Iterable<Option> options) => options.first;

        Option? _newlySelectedOption;
        final notSelectedOptions = optionsRight.toSet();
        await standaloneWidgetSetup(
          tester,
          widget: Swipe<Option>(
            key: const Key('fling'),
            onFling: flingCondition,
            controller: _controller,
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
            child: swipeableChild,
          ),
        );

        expect(_newlySelectedOption, isNull);
        expect(_controller, isNotNull);
        expect(_controller.isSelected(notSelectedOptions.first), isFalse);
        expect(_controller.isOpened, isFalse);

        await flingLeft(tester);
        expect(_controller.isSelected(flingCondition(notSelectedOptions)!),
            isTrue);
        expect(_newlySelectedOption, isNotNull);
        expect(_newlySelectedOption, equals(notSelectedOptions.first));
      },
    );

    testWidgets(
      'waitBeforeClosingDuration',
      (WidgetTester tester) async {
        await standaloneWidgetSetup(
          tester,
          widget: Swipe<Option>(
            key: const Key('waitBeforeClosingDuration'),
            controller: _controller,
            optionBuilder: (_, option, index, isSelected) {
              return SwipeOptionContainer<Option>(
                option: option,
                color: Colors.white,
                child: Text(option.toString()),
              );
            },
            optionsLeft: optionsLeft,
            optionsRight: optionsRight,
            child: swipeableChild,
            closeAnimationDuration: const Duration(milliseconds: 24),
            stayOpenedDuration: const Duration(milliseconds: 50),
            waitBeforeClosingDuration: const Duration(milliseconds: 20),
            expandSingleOptionDuration: const Duration(milliseconds: 12),
          ),
        );
        expect(_controller.isOpened, isFalse);
        await swipeLeft(tester);
        expect(_controller.isOpened, isTrue);
        await tester.pumpAndSettle();
        expect(_controller.isOpened, isFalse);
      },
      skip: true, //TODO: fix waitBeforeClosingDuration test
    );
  });
}
