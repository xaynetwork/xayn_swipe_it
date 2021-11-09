part of swipe;

/// The controller which is attached to a `Swipe` widget.
///
/// Use it to manage selected options, or to programmatically swipe open
/// the attached widget, to show a specific `Option`.
class SwipeController<Option> extends ChangeNotifier {
  Option? __optionToSelect;
  bool __isOpened = false;
  Set<Option> _selectedOptions = <Option>{};

  /// Constructs a new `Swipe` controller.
  SwipeController();

  /// Use this handler to check if a given [option] is selected or not.
  /// returns true is it is selected, false if it is not.
  bool isSelected(Option option) => _selectedOptions.contains(option);

  /// A handler to change the selection state of the given [option].
  /// If [isSelected] would not change the selection status of the [option],
  /// then the controller will ignore it.
  void updateSelection({required Option option, required bool isSelected}) {
    final isCurrentlySelected = _selectedOptions.contains(option);

    if (isSelected && !isCurrentlySelected) {
      _selectedOptions = {..._selectedOptions, option};
      notifyListeners();
    } else if (!isSelected && isCurrentlySelected) {
      _selectedOptions = {..._selectedOptions}..remove(option);
      notifyListeners();
    }
  }

  /// A handler to programmatically open up the swipe options, and display
  /// the presented [option].
  Future<void> swipeOpen(Option option) async {
    __optionToSelect = option;

    notifyListeners();
  }

  /// when true, the options widgets are visible, else if false,
  /// only the child is visible
  bool get isOpened => __isOpened;

  void _updateIsOpened(bool isOpened) {
    __isOpened = isOpened;

    notifyListeners();
  }

  /// Clear the set of selected options
  void _clearSelectedOptions() {
    _selectedOptions.clear();

    notifyListeners();
  }

  Option? get _optionToSelect {
    final value = __optionToSelect;

    __optionToSelect = null;

    return value;
  }
}
