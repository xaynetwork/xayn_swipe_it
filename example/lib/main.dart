import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:swipe/xayn_swipe_it.dart';

void main() {
  runApp(const MyApp());
}

/// A list of swipe options.
enum Option { one, two, three, four }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Swipe Widget'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SwipeController<Option>? _swipeController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Swipe<Option>(
            onController: (controller) {
              controller.updateSelection(option: Option.two, isSelected: true);

              _swipeController = controller;
            },
            onOptionTap: (option) {
              setState(() {});
            },
            onFling: (options) => options.first,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => log('text tapped'),
              child: const ColoredBox(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('Swipe me!'),
                ),
              ),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
            optionsLeft: (_swipeController?.isSelected(Option.one) ?? false)
                ? const [Option.one, Option.two]
                : const [Option.one, Option.three, Option.two],
            optionsRight: const [Option.three],
            selectedOptions: const {Option.one},
            optionBuilder: (context, option, index, isSelected) =>
                SwipeOptionContainer(
              option: option,
              color: index == 0
                  ? Colors.green
                  : index == 1
                      ? Colors.blue
                      : Colors.yellow,
              child: Center(
                child: Text(
                  '$index: $isSelected $option',
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: ElevatedButton(
        child: const Text('tap!'),
        onPressed: () {
          _swipeController?.swipeOpen(Option.one);
          //_swipeController?.updateSelection(option: Option.one, isSelected: !(_swipeController?.isSelected(Option.one)  ?? true));
        },
      ),
    );
  }
}
