# xayn_swipe_it

[![Pub](https://img.shields.io/pub/v/xayn_swipe_it.svg)](https://pub.dartlang.org/packages/xayn_swipe_it)
[![codecov](https://codecov.io/gh/xaynetwork/xayn_swipe_it/branch/main/graph/badge.svg)](https://codecov.io/gh/xaynetwork/xayn_swipe_it)
[![Build Status](https://github.com/xaynetwork/xayn_swipe_it/actions/workflows/flutter_post_merge.yaml/badge.svg)](https://github.com/xaynetwork/xayn_swipe_it/actions)

<img width="300" src="https://github.com/xaynetwork/xayn_swipe_it/blob/main/visuals/swipeIt.gif">

A performant, animated swipe widget with left and right customizable options that you can swipe or fling horizontally.

----------

## Table of content:

 * [Installing :hammer_and_wrench:](#installing-hammer_and_wrench)
 * [How to use :building_construction:](#how-to-use-building_construction)
 * [Visuals :heart_eyes_cat:](#visuals-heart_eyes_cat)
 * [Attributes :gear:](#attributes-gear)
 * [Troubleshooting :thinking:](#troubleshooting-thinking)
 * [Contributing :construction_worker_woman:](#contributing-construction_worker_woman)
 * [License :scroll:](#license-scroll)

----------

## Installing :hammer_and_wrench:

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  xayn_swipe_it: `latest version`
```

after that, shoot it on the command line:

```shell
$ flutter pub get
```

----------



## How to use :building_construction:

Use case #1 (Basic usage)
```dart
/// Define your own options
enum Option {like, dislike, share, skip, neutral}
```

```dart
/// Use it with `Swipe` widget
Swipe<Option>(
  onOptionTap: (option) => print(option.toString()),
  optionsLeft: const [Option.like, Option.share],
  optionsRight: const [Option.dislike, Option.skip],
  optionBuilder: (context, option, index, isSelected) => 
    SwipeOptionContainer(
        option: option,
        color: isSelected ? Colors.red : Colors.white,
        child: Center(
          child: Text(option.toString()),
        ),
      ),
  child: Container(
      child: Text('Swipe me!'),
    ),
);
```

Use case #2 (Controlling the `Swipe` widget)
```dart
/// Add to state
late SwipeController<Option> _swipeController;

/// Initialize the controller in initState
@override
void initState() {
  super.initState();
  _swipeController = SwipeController<Option>();
}
```

```dart
/// Pass the `SwipeController` to the `Swipe` widget 
Swipe<Option>(
  controller: _swipeController,
  ...
);
```

```dart
/// Now you can:
/// 1. Check if the `Swipe` is open and options are visible 
  final bool isCardOpened = _swipeController.isOpened;

/// 2. Check if a certain option is selected or not 
  final bool isOptionLiked = _swipeController.isSelected(Option.like);

/// 3. Manually select an option 
  _swipeController.updateSelection(option: Option.like, isSelected: true);

/// 4. Manually swipe the card to make an option visible
  await _swipeController.swipeOpen(Option.like);
```


Use case #3 (Flinging an option)
```dart
/// You can pass a condition of selecting an option in case of flinging the  `Swipe` 
/// widget in on horizontal direction 
Swipe<Option>(
  // Here we fling the first option in optionsLeft in case we flung right and vise versa 
  onFling: (options) => options.first,
  ...
);
```

Use case #4 (Disable options)
```dart
/// You can disable tapping on an option
Swipe<Option>( 
    optionBuilder: (context, option, index, isSelected) => 
      SwipeOptionContainer(
          // Here you disable an option in case it's selected
          isDisabled: isSelected,
          ...
          ),
        ),
  ...
);
```

Use case #5 (Passing a new option to optionBuilder)
```dart
/// You can use optionBuilder with options that are not passed to `optionsLeft` nor `optionsRight`
/// and it will trigger `onOptionTap` with the new tapped option 
Swipe<Option>( 
  optionsLeft: const [Option.like, Option.share],
  optionsRight: const [Option.dislike, Option.skip],
  optionBuilder: (context, option, index, isSelected) => 
    SwipeOptionContainer(
        option: Option.neutral,
        ...
      ),
  // Tapping the option will trigger onOptionTap with `Option.neutral` 
  onOptionTap: (option) => print(option.toString()),
  ...
);
```

Use case #6 (Alter like option to neutral in case it's selected)
```dart
/// State variables
SwipeController<Option> _swipeController  = SwipeController<Option>();
bool isLiked = false;

/// Add listener to changes in the SwipeController
_swipeController.addListener(() {
    setState(() {
      isLiked = _swipeController.isSelected(Option.like);
    });
});
```
```dart
Swipe<Option>(
  /// Pass the controller to the `Swipe` widget
  controller: _swipeController,

  /// If [isLiked] is true, then display a different list of Options
  optionsLeft: isLiked ? [Option.neutral, Option.share] : [Option.like, Option.share],
  ...
);
```

**Try out the [example](./example/lib/main.dart)**

[top :arrow_heading_up:](#xayn_swipe_it)

----------

## Visuals :heart_eyes_cat:

Curious how it will be looking? :smirk:

 |                          |                          |
 | ------------------------ | ------------------------ |
 | Select an option after swiping the card     | Fling to select an option      |
 | <img width="280" src="https://github.com/xaynetwork/xayn_swipe_it/blob/main/visuals/swipeItTap.gif"> | <img width="280" src="https://github.com/xaynetwork/xayn_swipe_it/blob/main/visuals/swipeItFling.gif"> |
 |                          |                          |

[top :arrow_heading_up:](#xayn_swipe_it)

----------

## Attributes :gear:

### Swipe
| attribute name   | Datatype		| Default Value | Description                                  |
| ---------------- | -------------- | ------------- | -------------------------------------------- |
| `child`          | `Widget`   	| `required`    | The content which should be the swipe target.|
| `optionBuilder`  | `OptionBuilder<Option>`| `required`    | Can be used to customize a single `Option`.    |
| `optionsLeft`          | `Iterable<Option>`   	| `[]`    | An `Iterable` representing the left-side `Option`s.    |
| `optionsRight`          | `Iterable<Option>`   	| `[]`    | An `Iterable` representing the right-side `Option`s.    |
| `selectedOptions`          | `Set<Option>`   	| `{}`    | Optionally used to pre-select any `Option` from either [optionsLeft] or [optionsRight].    |
| `onOptionTap`          | `OnOptionTap<Option>?`   	| `null`    | A handler which triggers whenever an `Option` is tapped.    |
| `swipeAreaBuilder`          | `WidgetBuilder?`   	| `null`    | By default, no UI elements are displayed to indicate that the child can indeed be swiped. If you want a custom UI to overlay the child, then provide this builder.    |
| `gestureArea`          | `Rect`   	| `Rect.zero`    | By default, the whole of [child] is covered with a [GestureDetector], if you want a custom area, then provide this parameter. For example, you can only allow gestures on the middle-area of the child.   |
| `closeAnimationDuration`          | `Duration`   	| `Duration(milliseconds: 240)`    | The `Duration` of the closing animation.    |
| `waitBeforeClosingDuration`          | `Duration`   	| `Duration(milliseconds: 1200)`    | The `Duration` that this widget waits before it closes any open swipe options, after the user tapped on one.    |
| `stayOpenedDuration`          | `Duration`   	| `Duration(seconds: 5)`    | The `Duration` of the idle stay open time.    |
| `closeAnimationCurve`          | `Curve`   	| `Curves.easeOut`    | The `Curve` which is used for the closing animation.    |
| `expandSingleOptionDuration`          | `Duration`   	| `Duration(milliseconds: 120)`    | The `Duration` for the transition animation when selecting an option. The option then transitions to overtake the fully available width, masking the other non-selected options.  |
| `singleOptionAnimationCurve`          | `Curve`   	| `Curves.easeOut`    | The `Curve` which is used for the closing animation for single option.    |
| `borderRadius`          | `BorderRadiusGeometry?`   	| `null`    | Can be used to show an optional border on the [child].    |
| `clipBehavior`          | `Clip`   	| `Clip.antiAlias`    | Specifies the clipping of the [child].    |
| `minDragDistanceToOpen`          | `double`   	| `.3`    | A value which defines how far the user needs to drag-open the swipe options. If not far enough, then on release the options close. If far enough, the options animate to fully open and the options are presented. Expects a value between 0.0 (zero width) and 1.0 (full available width).   |
| `opensToPosition`          | `double`   	| `.8`    | A value indicating to what percentage the options should open to. Expects a value between 0.0 (zero width) and 1.0 (full available width).   |
| `controller`          | `SwipeController<Option>?`   	| `null`    |  Provides the widget with a [SwipeController].    |
| `onFling`          | `OnFling<Option>?`   	| `null`    | A handler which expects an `Option` in return. When the user flings, then this option will be auto-selected.    |
| `autoToggleSelection`          | `bool`   	| `true`    | When true, then the [SwipeController] will notify the selection..    |

[top :arrow_heading_up:](#xayn_swipe_it)

----------

## Contributing :construction_worker_woman:

We're more than happy to accept pull requests :muscle:

 - check our [contributing](../main/.github/contributing.md) page
 - found a bug or have a question? Please [create an issue](https://github.com/xaynetwork/xayn_swipe_it/issues/new/choose).



[top :arrow_heading_up:](#xayn_swipe_it)

----------

## License :scroll:
**xayn_swipe_it** is licensed under `Apache 2`. View [license](../main/LICENSE).

[top :arrow_heading_up:](#xayn_swipe_it)

----------


