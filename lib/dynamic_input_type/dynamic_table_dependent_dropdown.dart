part of 'dynamic_table_input_type.dart';

class DynamicTableDependentDropDownInput<T extends Object, W extends Object>
    extends DynamicTableInputType<T> {
  DynamicTableDependentDropDownInput({
    required List<DropdownMenuItem<T>> Function(W dependentValue) itemsBuilder,
    required int dependentOnColumn,

    /// The value to display when the row is not editing.
    String Function(T? value)? displayBuilder,
    List<Widget> Function(BuildContext)? selectedItemBuilder,
    Widget? hint,
    Widget? disabledHint,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    Color? dropdownColor,
    InputDecoration? decoration,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
  })  : _itemsBuilder = itemsBuilder,
        _dependentOnColumn = dependentOnColumn,
        _displayBuilder = displayBuilder,
        _selectedItemBuilder = selectedItemBuilder,
        _hint = hint,
        _disabledHint = disabledHint,
        _elevation = elevation,
        _style = style,
        _icon = icon,
        _iconDisabledColor = iconDisabledColor,
        _iconEnabledColor = iconEnabledColor,
        _iconSize = iconSize,
        _isDense = isDense,
        _isExpanded = isExpanded,
        _itemHeight = itemHeight,
        _focusColor = focusColor,
        _dropdownColor = dropdownColor,
        _decoration = decoration,
        _menuMaxHeight = menuMaxHeight,
        _enableFeedback = enableFeedback,
        _alignment = alignment,
        _borderRadius = borderRadius,
        super(
        // dynamicTableInput: DynamicTableInput.dropdown,
        ) {
    dependentOn = _dependentOnColumn;
  }

  T? getFirstValue() {
    if (dependentValue == null) {
      return null;
    }
    return _itemsBuilder(dependentValue!).firstOrNull?.value;
  }

  bool hasSelectionValues(W dependentValue) {
    return _itemsBuilder(dependentValue).isNotEmpty;
  }

  @override
  Widget displayWidget(T? value, bool focused, void Function()? onEditComplete, ) {
    return DefaultDisplayWidget<T>(
      displayBuilder: _displayBuilder,
      value: value,
      focused: focused,
      onEditComplete: onEditComplete,
    );
  }

  @override
  Widget editingWidget(
      T? value,
      Function(T? value)? onChanged,
      void Function()? onEditComplete,
      void Function()? focusThisField,
      bool focused) {
    return DynamicTableDependentDropdownWidget<T, W>(
        dependentValue: dependentValue,
        itemsBuilder: _itemsBuilder,
        selectedItemBuilder: _selectedItemBuilder,
        hint: _hint,
        disabledHint: _disabledHint,
        elevation: _elevation,
        style: _style,
        icon: _icon,
        iconDisabledColor: _iconDisabledColor,
        iconEnabledColor: _iconEnabledColor,
        iconSize: _iconSize,
        isDense: _isDense,
        isExpanded: _isExpanded,
        itemHeight: _itemHeight,
        focusColor: _focusColor,
        dropdownColor: _dropdownColor,
        decoration: _decoration,
        menuMaxHeight: _menuMaxHeight,
        enableFeedback: _enableFeedback,
        alignment: _alignment,
        borderRadius: _borderRadius,
        value: value,
        onChanged: onChanged,
        onEditComplete: onEditComplete,
        focusThisField: focusThisField,
        focused: focused);
  }

  final List<DropdownMenuItem<T>> Function(W dependentValue) _itemsBuilder;
  final String Function(T?)? _displayBuilder;
  final List<Widget> Function(BuildContext)? _selectedItemBuilder;
  final Widget? _hint;
  final Widget? _disabledHint;
  final int _elevation;
  final TextStyle? _style;
  final Widget? _icon;
  final Color? _iconDisabledColor;
  final Color? _iconEnabledColor;
  final double _iconSize;
  final bool _isDense;
  final bool _isExpanded;
  final double? _itemHeight;
  final Color? _focusColor;
  final Color? _dropdownColor;
  final InputDecoration? _decoration;
  final double? _menuMaxHeight;
  final bool? _enableFeedback;
  final AlignmentGeometry _alignment;
  final BorderRadius? _borderRadius;

  W? dependentValue;
  int _dependentOnColumn;

  int get dependentOnColumn => _dependentOnColumn;

  @override
  void dispose() {}
}
