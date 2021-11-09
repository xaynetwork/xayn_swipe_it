import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future standaloneWidgetSetup(WidgetTester tester,
    {required Widget widget}) async {
  // Setup app and all dependencies
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    ),
  );
  await tester.pump();
}

const swipeableChildKeyName = 'swipeable_child';
const swipeableChildKey = Key(swipeableChildKeyName);
const swipeableChild = Text(
  'swipe me!',
  key: swipeableChildKey,
);

extension WidgetTestExtension on String {
  Finder findByKey() => find.byKey(Key(this));

  Finder findByText() => find.text(this);
}

enum Option { one, two, three, four }

const optionsLeft = [Option.one, Option.two];
const optionsRight = [Option.three, Option.four];

Finder getSwipeableChild() {
  final child = swipeableChildKeyName.findByKey();
  expect(child, findsOneWidget);
  return child;
}

Future<void> swipeLeft(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.drag(getSwipeableChild(), const Offset(-400, 0));
    await tester.idle();
  });
}

Future<void> swipeRight(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.drag(getSwipeableChild(), const Offset(400, 0));
    await tester.idle();
  });
}

Future<void> flingLeft(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.fling(getSwipeableChild(), const Offset(-1000, 0), 5000);
    await tester.pumpAndSettle();
  });
}
