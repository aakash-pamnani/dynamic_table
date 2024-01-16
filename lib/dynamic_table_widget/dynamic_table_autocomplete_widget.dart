import 'package:dynamic_table/dynamic_table_source/dynamic_table_view.dart';
import 'package:dynamic_table/dynamic_table_widget/focusing_extension.dart';
import 'package:dynamic_table/dynamic_table_widget/key_event_handlers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicTableAutocompleteWidget extends StatefulWidget {
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
  State<DynamicTableAutocompleteWidget> createState() => _DynamicTableAutocompleteWidgetState();
}

class _DynamicTableAutocompleteWidgetState extends State<DynamicTableAutocompleteWidget> {
  FocusNode? _focusNode;
  TextEditingController? _textEditingController;
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: widget._optionsBuilder,
      displayStringForOption: widget._displayStringForOption,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        if (textEditingController.text != widget.value) textEditingController.text = widget.value ?? "";
        textEditingController.addListener(() {
          widget.onChanged?.call(
            textEditingController.text,
          );
        });

        _textEditingController = textEditingController;
        _focusNode = focusNode;
        widget.touchEditCallBacks.updateFocusCache?.call(identity: this, () => setState(() {
          focusNode.unfocus();
        }), () => focusNode);

        focusNode.addListener(() {
          if ((focusNode.hasFocus) && !widget.focused) {
            widget.touchEditCallBacks.focusThisEditingField?.call();
          }
        });

        focusNode.onKeyEvent = (node, event) => event
            .handleKeysIfCallBackExistAndCallOnlyOnKeyDown(
                [LogicalKeyboardKey.tab],
                widget.touchEditCallBacks.focusPreviousField, withShift: true)
                .chain([LogicalKeyboardKey.enter, LogicalKeyboardKey.tab], widget.touchEditCallBacks.focusNextField)
                .chain([LogicalKeyboardKey.escape], widget.touchEditCallBacks.cancelEdit).result();
        focusNode.focus(widget.focused);
        return widget._fieldViewBuilder(
            context, textEditingController, focusNode, onFieldSubmitted);
      },
      onSelected: (value) {
        widget._onSelected?.call(value);
        widget.touchEditCallBacks.focusNextField?.call();
      },
      optionsMaxHeight: widget._optionsMaxHeight,
      optionsViewBuilder: widget._optionsViewBuilder,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode?.unfocus();
    _focusNode?.dispose();
    _focusNode = null;
    _textEditingController?.dispose();
    _textEditingController = null;
    widget.touchEditCallBacks.clearFocusCache?.call(identity: this);
  }
}
