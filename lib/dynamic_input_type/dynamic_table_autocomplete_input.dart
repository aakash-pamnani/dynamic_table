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
        _displayBuilder = displayBuilder,
        _onSelected = onSelected,
        _optionsMaxHeight = optionsMaxHeight,
        _optionsViewBuilder = optionsViewBuilder,
        _fieldViewBuilder = fieldViewBuilder?? _defaultFieldViewBuilder,
        super(
        // dynamicTableInput: DynamicTableInput.dropdown,
        ) {
    
  }

  final AutocompleteOptionsBuilder<String> _optionsBuilder;
  final AutocompleteOptionToString<String> _displayStringForOption;
  final AutocompleteFieldViewBuilder _fieldViewBuilder;
  final String Function(String? value)? _displayBuilder;
  final AutocompleteOnSelected<String>? _onSelected;
  final double _optionsMaxHeight;
  final AutocompleteOptionsViewBuilder<String>? _optionsViewBuilder;

  @override
  Widget displayWidget(String? value, bool focused) {
    return DefaultDisplayWidget<String>(
      displayBuilder: _displayBuilder,
      value: value,
      focused: focused,
    );
  }

  static Widget _defaultFieldViewBuilder(
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
      void Function(int row, int column)? onEditComplete,
      int row,
      int column,
      bool focused) {
    return DynamicTableAutocompleteWidget(
        optionsBuilder: _optionsBuilder,
        displayStringForOption: _displayStringForOption,
        fieldViewBuilder: _fieldViewBuilder,
        onSelected: _onSelected,
        optionsMaxHeight: _optionsMaxHeight,
        optionsViewBuilder: _optionsViewBuilder,
        value: value,
        onChanged: onChanged,
        onEditComplete: onEditComplete,
        row: row,
        column: column,
        focused: focused);
  }

  @override
  void dispose() {}
}
