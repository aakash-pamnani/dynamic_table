part of 'dynamic_table_input_type.dart';

class DynamicTableAutocompleteInput extends DynamicTableInputType<String> {
  DynamicTableAutocompleteInput({
    required AutocompleteOptionsBuilder<String> optionsBuilder,
    AutocompleteOptionToString<String> displayStringForOption =
        RawAutocomplete.defaultStringForOption,
    AutocompleteFieldViewBuilder? fieldViewBuilder,
    String Function(String? value)? displayBuilder,
    AutocompleteOnSelected<String>? onSelected,
    double optionsMaxHeight = 200.0,
    AutocompleteOptionsViewBuilder<String>? optionsViewBuilder,
  })  : _optionsBuilder = optionsBuilder,
        _displayStringForOption = displayStringForOption,
        _fieldViewBuilder = fieldViewBuilder,
        _displayBuilder = displayBuilder,
        _onSelected = onSelected,
        _optionsMaxHeight = optionsMaxHeight,
        _optionsViewBuilder = optionsViewBuilder,
        super(
        // dynamicTableInput: DynamicTableInput.dropdown,
        ) {
    _fieldViewBuilder ??= _defaultFieldViewBuilder;
  }

  final AutocompleteOptionsBuilder<String> _optionsBuilder;
  final AutocompleteOptionToString<String> _displayStringForOption;
  AutocompleteFieldViewBuilder? _fieldViewBuilder;
  final String Function(String? value)? _displayBuilder;
  final AutocompleteOnSelected<String>? _onSelected;
  final double _optionsMaxHeight;
  final AutocompleteOptionsViewBuilder<String>? _optionsViewBuilder;

  @override
  Widget displayWidget(String? value) {
    return Text((_displayBuilder ?? _defaultDisplayBuilder).call(value));
  }

  String _defaultDisplayBuilder(String? value) {
    return value.toString();
  }

  Widget _defaultFieldViewBuilder(
      BuildContext context,
      TextEditingController textEditingController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted) {
    return TextFormField(
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (_) => onFieldSubmitted(),
    );
  }

  @override
  Widget editingWidget(
      String? value,
      Function(String value, int row, int column)? onChanged,
      int row,
      int column) {
    return Autocomplete<String>(
      // initialValue: TextEditingValue(
      //     text: (_displayBuilder ?? _defaultDisplayBuilder).call(value)),
      optionsBuilder: _optionsBuilder,
      displayStringForOption: _displayStringForOption,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        textEditingController.text = value ?? "";
        textEditingController.addListener(() {
          onChanged?.call(textEditingController.text, row, column);
        });
        return _fieldViewBuilder!(
            context, textEditingController, focusNode, onFieldSubmitted);
      },
      onSelected: _onSelected,
      optionsMaxHeight: _optionsMaxHeight,
      optionsViewBuilder: _optionsViewBuilder,
    );
  }

  @override
  void dispose() {
    // _textEditingController?.dispose();
    // _textEditingController = null;
  }
}
