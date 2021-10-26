import 'package:flutter/widgets.dart';

class SwipeController<Option> extends ChangeNotifier {
  Option? _optionToSelect;
  Set<Option> _selectedOptions = const {};

  SwipeController();

  Option? get optionToSelect {
    final value = _optionToSelect;

    _optionToSelect = null;

    return value;
  }

  bool isSelected(Option option) => _selectedOptions.contains(option);

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

  Future<void> swipeOpen(Option option) async {
    _optionToSelect = option;
    notifyListeners();
  }
}
