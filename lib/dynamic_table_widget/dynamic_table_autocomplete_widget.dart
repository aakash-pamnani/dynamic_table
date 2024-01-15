import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/key_event_handlers.dart';
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
    required this.touchEditCallBacks,
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
  final Function(
    String value,
  )? onChanged;
  final TouchEditCallBacks touchEditCallBacks;
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
          onChanged?.call(
            textEditingController.text,
          );
        });

        focusNode.addListener(() {
          if ((focusNode.hasFocus) && !focused) {
            touchEditCallBacks.focusThisEditingField?.call();
          }
        });

        focusNode.onKeyEvent = (node, event) => event
            .handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
                [LogicalKeyboardKey.tab],
                touchEditCallBacks.focusPreviousField, withShift: true)
                .chain([LogicalKeyboardKey.enter, LogicalKeyboardKey.tab], touchEditCallBacks.focusNextField)
                .chain([LogicalKeyboardKey.escape], touchEditCallBacks.cancelEdit).result();
        focusNode.focus(focused);
        return _fieldViewBuilder(
            context, textEditingController, focusNode, onFieldSubmitted);
      },
      onSelected: (value) {
        _onSelected?.call(value);
        touchEditCallBacks.focusNextField?.call();
      },
      optionsMaxHeight: _optionsMaxHeight,
      optionsViewBuilder: _optionsViewBuilder,
    );
  }
}
