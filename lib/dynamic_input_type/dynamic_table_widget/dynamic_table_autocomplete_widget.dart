import 'package:dynamic_table/dynamic_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicTableAutocompleteWidget extends StatelessWidget {
  const DynamicTableAutocompleteWidget({
    super.key,
    required AutocompleteOptionsBuilder<String> optionsBuilder,
    required AutocompleteOptionToString<String> displayStringForOption,
    required AutocompleteFieldViewBuilder fieldViewBuilder,
    required AutocompleteOnSelected<String>? onSelected,
    required double optionsMaxHeight,
    required AutocompleteOptionsViewBuilder<String>? optionsViewBuilder,
    required this.value,
    required this.onChanged,
    required this.onEditComplete,
    required this.row,
    required this.column,
    required this.focused,
  })  : _optionsBuilder = optionsBuilder,
        _displayStringForOption = displayStringForOption,
        _fieldViewBuilder = fieldViewBuilder,
        _onSelected = onSelected,
        _optionsMaxHeight = optionsMaxHeight,
        _optionsViewBuilder = optionsViewBuilder;

  final AutocompleteOptionsBuilder<String> _optionsBuilder;
  final AutocompleteOptionToString<String> _displayStringForOption;
  final AutocompleteFieldViewBuilder _fieldViewBuilder;
  final AutocompleteOnSelected<String>? _onSelected;
  final double _optionsMaxHeight;
  final AutocompleteOptionsViewBuilder<String>? _optionsViewBuilder;
  final String? value;
  final Function(String value, int row, int column)? onChanged;
  final void Function(int row, int column)? onEditComplete;
  final int row;
  final int column;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: _optionsBuilder,
      displayStringForOption: _displayStringForOption,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        textEditingController.text = value ?? "";
        textEditingController.addListener(() {
          onChanged?.call(textEditingController.text, row, column);
        });

        focusNode.onKeyEvent = (node, event) {
          if (onEditComplete != null &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.tab)) if (event
              is KeyDownEvent) {
            onEditComplete?.call(row, column);
            return KeyEventResult.handled;
          } else
            return KeyEventResult.handled;
          return KeyEventResult.ignored;
        };
        focusNode.focus(focused);
        return _fieldViewBuilder(
            context, textEditingController, focusNode, onFieldSubmitted);
      },
      onSelected: (value) {
        _onSelected?.call(value);
        onEditComplete?.call(row, column);
      },
      optionsMaxHeight: _optionsMaxHeight,
      optionsViewBuilder: _optionsViewBuilder,
    );
  }
}
